package service

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/simontarrant/summit-spec/apps/api/internal/model"
)

type SearchService struct {
	pool *pgxpool.Pool
}

func NewSearchService(pool *pgxpool.Pool) *SearchService {
	return &SearchService{pool: pool}
}

func (s *SearchService) Search(ctx context.Context, req model.SearchRequest) (*model.SearchResponse, error) {
	if req.Limit <= 0 || req.Limit > 100 {
		req.Limit = 25
	}
	if req.Offset < 0 {
		req.Offset = 0
	}

	catID, err := strconv.ParseInt(req.CategoryID, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid categoryId: %w", err)
	}

	// Build query
	params := []interface{}{}
	paramIdx := 0
	nextParam := func(v interface{}) string {
		paramIdx++
		params = append(params, v)
		return fmt.Sprintf("$%d", paramIdx)
	}

	// Category filter
	catParam := nextParam(catID)

	var whereClauses []string
	whereClauses = append(whereClauses, fmt.Sprintf("%s = ANY(category_ids)", catParam))

	// Apply filters
	for _, f := range req.Filters {
		clause, err := buildFilterClause(f, nextParam)
		if err != nil {
			return nil, fmt.Errorf("filter error: %w", err)
		}
		if clause != "" {
			whereClauses = append(whereClauses, clause)
		}
	}

	whereSQL := strings.Join(whereClauses, " AND ")

	// Sort
	orderSQL := "product_name ASC, brand_name ASC, product_id ASC, variant_id ASC"
	if req.Sort != nil {
		sortClause, err := buildSortClause(req.Sort)
		if err != nil {
			return nil, fmt.Errorf("sort error: %w", err)
		}
		orderSQL = sortClause
	}

	// Count query
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM search_product_variant WHERE %s", whereSQL)
	var totalRows int
	if err := s.pool.QueryRow(ctx, countSQL, params...).Scan(&totalRows); err != nil {
		return nil, fmt.Errorf("count query: %w", err)
	}

	// Data query
	limitParam := nextParam(req.Limit)
	offsetParam := nextParam(req.Offset)

	dataSQL := fmt.Sprintf(`
		SELECT variant_id, product_id, product_name, variant_name,
		       brand_id, brand_name, primary_category_id,
		       number_attrs, bool_attrs, enum_attrs, string_attrs
		FROM search_product_variant
		WHERE %s
		ORDER BY %s
		LIMIT %s OFFSET %s
	`, whereSQL, orderSQL, limitParam, offsetParam)

	rows, err := s.pool.Query(ctx, dataSQL, params...)
	if err != nil {
		return nil, fmt.Errorf("data query: %w", err)
	}
	defer rows.Close()

	var results []model.SearchRow
	for rows.Next() {
		var (
			variantID, productID, brandID, primaryCatID int64
			productName, brandName                      string
			variantName                                 *string
			numberAttrs, boolAttrs, enumAttrs, strAttrs json.RawMessage
		)
		if err := rows.Scan(
			&variantID, &productID, &productName, &variantName,
			&brandID, &brandName, &primaryCatID,
			&numberAttrs, &boolAttrs, &enumAttrs, &strAttrs,
		); err != nil {
			return nil, fmt.Errorf("scan row: %w", err)
		}

		vn := ""
		if variantName != nil {
			vn = *variantName
		}

		attrs := buildAttributes(numberAttrs, boolAttrs, enumAttrs, strAttrs)

		results = append(results, model.SearchRow{
			VariantID:         strconv.FormatInt(variantID, 10),
			ProductID:         strconv.FormatInt(productID, 10),
			ProductName:       productName,
			VariantName:       vn,
			BrandID:           strconv.FormatInt(brandID, 10),
			BrandName:         brandName,
			PrimaryCategoryID: strconv.FormatInt(primaryCatID, 10),
			Attributes:        attrs,
		})
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate rows: %w", err)
	}

	if results == nil {
		results = []model.SearchRow{}
	}

	return &model.SearchResponse{
		Rows: results,
		Pagination: model.Pagination{
			Limit:     req.Limit,
			Offset:    req.Offset,
			TotalRows: totalRows,
		},
	}, nil
}

func buildFilterClause(f model.Filter, nextParam func(interface{}) string) (string, error) {
	switch f.Type {
	case "number":
		return buildNumberFilter(f, nextParam)
	case "bool":
		return buildBoolFilter(f, nextParam)
	case "enum_list":
		return buildEnumFilter(f, nextParam)
	case "string":
		return buildStringFilter(f, nextParam)
	default:
		return "", fmt.Errorf("unknown filter type: %s", f.Type)
	}
}

func buildNumberFilter(f model.Filter, nextParam func(interface{}) string) (string, error) {
	attrKey := f.AttributeID

	op := f.Operator
	if op == "" {
		op = "gte"
	}

	switch op {
	case "eq":
		var v float64
		if err := json.Unmarshal(f.Value, &v); err != nil {
			return "", fmt.Errorf("invalid number value: %w", err)
		}
		p := nextParam(v)
		return fmt.Sprintf("(number_attrs->>'%s')::numeric = %s", attrKey, p), nil

	case "gte":
		var v float64
		if err := json.Unmarshal(f.Value, &v); err != nil {
			return "", fmt.Errorf("invalid number value: %w", err)
		}
		p := nextParam(v)
		return fmt.Sprintf("(number_attrs->>'%s')::numeric >= %s", attrKey, p), nil

	case "lte":
		var v float64
		if err := json.Unmarshal(f.Value, &v); err != nil {
			return "", fmt.Errorf("invalid number value: %w", err)
		}
		p := nextParam(v)
		return fmt.Sprintf("(number_attrs->>'%s')::numeric <= %s", attrKey, p), nil

	case "between":
		var v [2]float64
		if err := json.Unmarshal(f.Value, &v); err != nil {
			return "", fmt.Errorf("invalid between value: %w", err)
		}
		pMin := nextParam(v[0])
		pMax := nextParam(v[1])
		return fmt.Sprintf("(number_attrs->>'%s')::numeric >= %s AND (number_attrs->>'%s')::numeric <= %s",
			attrKey, pMin, attrKey, pMax), nil

	default:
		return "", fmt.Errorf("unknown number operator: %s", op)
	}
}

func buildBoolFilter(f model.Filter, nextParam func(interface{}) string) (string, error) {
	var v bool
	if err := json.Unmarshal(f.Value, &v); err != nil {
		return "", fmt.Errorf("invalid bool value: %w", err)
	}
	p := nextParam(v)
	return fmt.Sprintf("(bool_attrs->>'%s')::boolean = %s", f.AttributeID, p), nil
}

func buildEnumFilter(f model.Filter, nextParam func(interface{}) string) (string, error) {
	var vals []string
	if err := json.Unmarshal(f.Value, &vals); err != nil {
		return "", fmt.Errorf("invalid enum_list value: %w", err)
	}
	if len(vals) == 0 {
		return "", fmt.Errorf("enum_list filter requires at least one value")
	}

	// Convert string IDs to int64 for comparison
	intVals := make([]int64, len(vals))
	for i, v := range vals {
		id, err := strconv.ParseInt(v, 10, 64)
		if err != nil {
			return "", fmt.Errorf("invalid enum value id: %w", err)
		}
		intVals[i] = id
	}
	p := nextParam(intVals)
	return fmt.Sprintf("(enum_attrs->>'%s')::bigint = ANY(%s)", f.AttributeID, p), nil
}

func buildStringFilter(f model.Filter, nextParam func(interface{}) string) (string, error) {
	var v string
	if err := json.Unmarshal(f.Value, &v); err != nil {
		return "", fmt.Errorf("invalid string value: %w", err)
	}
	p := nextParam(v)
	return fmt.Sprintf("string_attrs->>'%s' = %s", f.AttributeID, p), nil
}

func buildSortClause(sort *model.Sort) (string, error) {
	dir := "ASC"
	if sort.Direction == "desc" {
		dir = "DESC"
	}

	attrKey := sort.AttributeID
	// Try number first, then string, then bool — the COALESCE picks whichever is non-null
	return fmt.Sprintf(
		`(number_attrs->>'%s')::numeric %s NULLS LAST, `+
			`string_attrs->>'%s' %s NULLS LAST, `+
			`product_name ASC, brand_name ASC, product_id ASC, variant_id ASC`,
		attrKey, dir, attrKey, dir,
	), nil
}

func buildAttributes(numberRaw, boolRaw, enumRaw, strRaw json.RawMessage) map[string]model.AttributeValue {
	attrs := make(map[string]model.AttributeValue)

	var numberMap map[string]json.Number
	if err := json.Unmarshal(numberRaw, &numberMap); err == nil {
		for k, v := range numberMap {
			f, err := v.Float64()
			if err == nil {
				attrs[k] = model.AttributeValue{Type: "number", Value: f}
			}
		}
	}

	var boolMap map[string]bool
	if err := json.Unmarshal(boolRaw, &boolMap); err == nil {
		for k, v := range boolMap {
			attrs[k] = model.AttributeValue{Type: "bool", Value: v}
		}
	}

	var enumMap map[string]json.Number
	if err := json.Unmarshal(enumRaw, &enumMap); err == nil {
		for k, v := range enumMap {
			// Store as enum ID — frontend resolves the display value from schema
			attrs[k] = model.AttributeValue{Type: "enum_list", Value: v.String()}
		}
	}

	var strMap map[string]string
	if err := json.Unmarshal(strRaw, &strMap); err == nil {
		for k, v := range strMap {
			attrs[k] = model.AttributeValue{Type: "string", Value: v}
		}
	}

	return attrs
}
