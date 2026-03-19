package service

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/simontarrant/summit-spec/apps/api/internal/model"
)

type SchemaService struct {
	pool *pgxpool.Pool
}

func NewSchemaService(pool *pgxpool.Pool) *SchemaService {
	return &SchemaService{pool: pool}
}

// catRow is the raw row shape from the category query.
type catRow struct {
	ID       int64
	Slug     string
	Name     string
	ParentID *int64
}

// catAttrRow is the raw row shape from the category_attribute + attribute join.
type catAttrRow struct {
	CatID      int64
	AttrFK     int64
	Priority   int
	AttrID     int64
	Slug       string
	Name       string
	AttrType   string
	NumberUnit string
}

// enumValRow is the raw row shape from the enum_attribute_vals query.
type enumValRow struct {
	ID           int64
	AttrID       int64
	Slug         string
	Name         string
	DisplayOrder int
}

func (s *SchemaService) GetSchema(ctx context.Context) (*model.SchemaResponse, error) {
	cats, err := s.fetchCategories(ctx)
	if err != nil {
		return nil, err
	}

	roots := buildCategoryTree(cats)

	caRows, err := s.fetchCategoryAttributes(ctx)
	if err != nil {
		return nil, err
	}

	attributes, categoryAttributes, enumAttrIDs := buildAttributeMaps(caRows)

	if err := s.attachEnumOptions(ctx, attributes, enumAttrIDs); err != nil {
		return nil, err
	}

	return &model.SchemaResponse{
		Categories:         roots,
		Attributes:         attributes,
		CategoryAttributes: categoryAttributes,
	}, nil
}

func (s *SchemaService) fetchCategories(ctx context.Context) ([]catRow, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, slug, name, parent_category
		FROM category
		WHERE is_deleted = false
		ORDER BY id ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("query categories: %w", err)
	}
	defer rows.Close()

	var cats []catRow
	for rows.Next() {
		var c catRow
		if err := rows.Scan(&c.ID, &c.Slug, &c.Name, &c.ParentID); err != nil {
			return nil, fmt.Errorf("scan category: %w", err)
		}
		cats = append(cats, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate categories: %w", err)
	}
	return cats, nil
}

func (s *SchemaService) fetchCategoryAttributes(ctx context.Context) ([]catAttrRow, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT
			ca.category, ca.attribute, ca.priority,
			a.id, a.slug, a.name, a.type, a.number_unit
		FROM category_attribute ca
		JOIN attribute a ON a.id = ca.attribute AND a.is_deleted = false
		JOIN category c ON c.id = ca.category AND c.is_deleted = false
		WHERE ca.is_deleted = false
		ORDER BY ca.category, ca.priority DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("query category_attributes: %w", err)
	}
	defer rows.Close()

	var result []catAttrRow
	for rows.Next() {
		var r catAttrRow
		if err := rows.Scan(&r.CatID, &r.AttrFK, &r.Priority, &r.AttrID, &r.Slug, &r.Name, &r.AttrType, &r.NumberUnit); err != nil {
			return nil, fmt.Errorf("scan category_attribute: %w", err)
		}
		result = append(result, r)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate category_attributes: %w", err)
	}
	return result, nil
}

// buildCategoryTree assembles flat category rows into a tree of CategoryNode roots.
// Input rows must be ordered by id ASC so that parents appear before children.
func buildCategoryTree(cats []catRow) []model.CategoryNode {
	type node struct {
		id       string
		slug     string
		name     string
		parentID string
		children []string // child IDs in insertion order
	}

	nodes := make(map[string]*node, len(cats))
	orderedIDs := make([]string, 0, len(cats))

	for _, c := range cats {
		id := fmt.Sprintf("%d", c.ID)
		n := &node{id: id, slug: c.Slug, name: c.Name}
		if c.ParentID != nil {
			n.parentID = fmt.Sprintf("%d", *c.ParentID)
		}
		nodes[id] = n
		orderedIDs = append(orderedIDs, id)
	}

	// Link children to parents
	rootIDs := make([]string, 0)
	for _, id := range orderedIDs {
		n := nodes[id]
		if n.parentID != "" {
			if parent, ok := nodes[n.parentID]; ok {
				parent.children = append(parent.children, id)
				continue
			}
		}
		rootIDs = append(rootIDs, id)
	}

	// Recursively build the model tree from the linked nodes
	var build func(id string) model.CategoryNode
	build = func(id string) model.CategoryNode {
		n := nodes[id]
		children := make([]model.CategoryNode, 0, len(n.children))
		for _, childID := range n.children {
			children = append(children, build(childID))
		}
		return model.CategoryNode{
			ID:       n.id,
			Slug:     n.slug,
			Name:     n.name,
			Children: children,
		}
	}

	roots := make([]model.CategoryNode, 0, len(rootIDs))
	for _, id := range rootIDs {
		roots = append(roots, build(id))
	}
	return roots
}

// buildAttributeMaps converts flat catAttrRows into deduplicated attribute definitions
// and per-category attribute entry lists. Returns the list of enum_list attribute IDs
// that need their options fetched.
func buildAttributeMaps(rows []catAttrRow) (
	attributes map[string]model.AttributeDef,
	categoryAttributes map[string][]model.CategoryAttrEntry,
	enumAttrIDs []int64,
) {
	attributes = make(map[string]model.AttributeDef)
	categoryAttributes = make(map[string][]model.CategoryAttrEntry)

	for _, r := range rows {
		attrIDStr := fmt.Sprintf("%d", r.AttrID)
		catIDStr := fmt.Sprintf("%d", r.CatID)

		if _, exists := attributes[attrIDStr]; !exists {
			attributes[attrIDStr] = model.AttributeDef{
				ID:         attrIDStr,
				Slug:       r.Slug,
				Name:       r.Name,
				Type:       r.AttrType,
				NumberUnit: r.NumberUnit,
			}
			if r.AttrType == "enum_list" {
				enumAttrIDs = append(enumAttrIDs, r.AttrID)
			}
		}

		categoryAttributes[catIDStr] = append(categoryAttributes[catIDStr], model.CategoryAttrEntry{
			AttributeID: attrIDStr,
			Priority:    r.Priority,
		})
	}
	return
}

// attachEnumOptions fetches enum values for the given attribute IDs and attaches
// them to the corresponding entries in the attributes map.
func (s *SchemaService) attachEnumOptions(ctx context.Context, attributes map[string]model.AttributeDef, enumAttrIDs []int64) error {
	if len(enumAttrIDs) == 0 {
		return nil
	}

	enumVals, err := s.fetchEnumValues(ctx, enumAttrIDs)
	if err != nil {
		return err
	}

	for _, ev := range enumVals {
		attrIDStr := fmt.Sprintf("%d", ev.AttrID)
		if attr, ok := attributes[attrIDStr]; ok {
			attr.EnumOptions = append(attr.EnumOptions, model.EnumOption{
				ID:           fmt.Sprintf("%d", ev.ID),
				Slug:         ev.Slug,
				Name:         ev.Name,
				DisplayOrder: ev.DisplayOrder,
			})
			attributes[attrIDStr] = attr
		}
	}
	return nil
}

func (s *SchemaService) fetchEnumValues(ctx context.Context, attrIDs []int64) ([]enumValRow, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, attribute, slug, name, display_order
		FROM enum_attribute_vals
		WHERE attribute = ANY($1) AND is_deleted = false
		ORDER BY attribute, display_order ASC
	`, attrIDs)
	if err != nil {
		return nil, fmt.Errorf("query enum_attribute_vals: %w", err)
	}
	defer rows.Close()

	var result []enumValRow
	for rows.Next() {
		var r enumValRow
		if err := rows.Scan(&r.ID, &r.AttrID, &r.Slug, &r.Name, &r.DisplayOrder); err != nil {
			return nil, fmt.Errorf("scan enum_attribute_val: %w", err)
		}
		result = append(result, r)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate enum_attribute_vals: %w", err)
	}
	return result, nil
}
