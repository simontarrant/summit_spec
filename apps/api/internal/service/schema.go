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

func (s *SchemaService) GetSchema(ctx context.Context) (*model.SchemaResponse, error) {
	// Fetch categories
	catRows, err := s.pool.Query(ctx, `
		SELECT id, slug, name, parent_category
		FROM category
		WHERE is_deleted = false
		ORDER BY id ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("query categories: %w", err)
	}
	defer catRows.Close()

	type catRow struct {
		id       int64
		slug     string
		name     string
		parentID *int64
	}
	var cats []catRow
	for catRows.Next() {
		var c catRow
		if err := catRows.Scan(&c.id, &c.slug, &c.name, &c.parentID); err != nil {
			return nil, fmt.Errorf("scan category: %w", err)
		}
		cats = append(cats, c)
	}
	if err := catRows.Err(); err != nil {
		return nil, fmt.Errorf("iterate categories: %w", err)
	}

	// Build category tree
	nodeMap := make(map[string]*model.CategoryNode)
	parentMap := make(map[string]string)
	for _, c := range cats {
		id := fmt.Sprintf("%d", c.id)
		nodeMap[id] = &model.CategoryNode{
			ID:       id,
			Slug:     c.slug,
			Name:     c.name,
			Children: []model.CategoryNode{},
		}
		if c.parentID != nil {
			parentMap[id] = fmt.Sprintf("%d", *c.parentID)
		}
	}

	var roots []model.CategoryNode
	for id, node := range nodeMap {
		parentID, hasParent := parentMap[id]
		if hasParent {
			if parent, ok := nodeMap[parentID]; ok {
				parent.Children = append(parent.Children, *node)
				continue
			}
		}
		roots = append(roots, *node)
	}

	// Fetch category_attributes with attribute details
	caRows, err := s.pool.Query(ctx, `
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
	defer caRows.Close()

	attributes := make(map[string]model.AttributeDef)
	categoryAttributes := make(map[string][]model.CategoryAttrEntry)
	var enumAttrIDs []int64

	for caRows.Next() {
		var (
			catID, attrFK   int64
			priority        int
			attrID          int64
			slug, name      string
			attrType        string
			numberUnit      string
		)
		if err := caRows.Scan(&catID, &attrFK, &priority, &attrID, &slug, &name, &attrType, &numberUnit); err != nil {
			return nil, fmt.Errorf("scan category_attribute: %w", err)
		}

		attrIDStr := fmt.Sprintf("%d", attrID)
		catIDStr := fmt.Sprintf("%d", catID)

		if _, exists := attributes[attrIDStr]; !exists {
			attributes[attrIDStr] = model.AttributeDef{
				ID:         attrIDStr,
				Slug:       slug,
				Name:       name,
				Type:       attrType,
				NumberUnit: numberUnit,
			}
			if attrType == "enum_list" {
				enumAttrIDs = append(enumAttrIDs, attrID)
			}
		}

		categoryAttributes[catIDStr] = append(categoryAttributes[catIDStr], model.CategoryAttrEntry{
			AttributeID: attrIDStr,
			Priority:    priority,
		})
	}
	if err := caRows.Err(); err != nil {
		return nil, fmt.Errorf("iterate category_attributes: %w", err)
	}

	// Fetch enum values for enum_list attributes
	if len(enumAttrIDs) > 0 {
		enumRows, err := s.pool.Query(ctx, `
			SELECT id, attribute, slug, name, display_order
			FROM enum_attribute_vals
			WHERE attribute = ANY($1) AND is_deleted = false
			ORDER BY attribute, display_order ASC
		`, enumAttrIDs)
		if err != nil {
			return nil, fmt.Errorf("query enum_attribute_vals: %w", err)
		}
		defer enumRows.Close()

		for enumRows.Next() {
			var (
				id, attrID   int64
				slug, name   string
				displayOrder int
			)
			if err := enumRows.Scan(&id, &attrID, &slug, &name, &displayOrder); err != nil {
				return nil, fmt.Errorf("scan enum_attribute_val: %w", err)
			}

			attrIDStr := fmt.Sprintf("%d", attrID)
			if attr, ok := attributes[attrIDStr]; ok {
				attr.EnumOptions = append(attr.EnumOptions, model.EnumOption{
					ID:           fmt.Sprintf("%d", id),
					Slug:         slug,
					Name:         name,
					DisplayOrder: displayOrder,
				})
				attributes[attrIDStr] = attr
			}
		}
		if err := enumRows.Err(); err != nil {
			return nil, fmt.Errorf("iterate enum_attribute_vals: %w", err)
		}
	}

	return &model.SchemaResponse{
		Categories:         roots,
		Attributes:         attributes,
		CategoryAttributes: categoryAttributes,
	}, nil
}
