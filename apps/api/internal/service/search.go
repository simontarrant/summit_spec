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

// searchQuery holds the built SQL and parameters for both the count and data queries.
type searchQuery struct {
	whereSQL string
	orderSQL string
	params   []interface{}
}

func (s *SearchService) Search(ctx context.Context, req model.SearchRequest) (*model.SearchResponse, error) {
	req = normalizeRequest(req)

	q, err := buildSearchQuery(req)
	if err != nil {
		return nil, err
	}

	totalRows, err := s.executeCount(ctx, q)
	if err != nil {
		return nil, err
	}

	rows, err := s.executeSearch(ctx, q, req.Limit, req.Offset)
	if err != nil {
		return nil, err
	}

	return &model.SearchResponse{
		Rows: rows,
		Pagination: model.Pagination{
			Limit:     req.Limit,
			Offset:    req.Offset,
			TotalRows: totalRows,
		},
	}, nil
}

func normalizeRequest(req model.SearchRequest) model.SearchRequest {
	if req.Limit <= 0 || req.Limit > 100 {
		req.Limit = 25
	}
	if req.Offset < 0 {
		req.Offset = 0
	}
	return req
}

// buildSearchQuery validates the request and produces the WHERE/ORDER SQL plus params.
func buildSearchQuery(req model.SearchRequest) (*searchQuery, error) {
	catID, err := strconv.ParseInt(req.CategoryID, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid categoryId: %w", err)
	}

	params := []interface{}{}
	paramIdx := 0
	nextParam := func(v interface{}) string {
		paramIdx++
		params = append(params, v)
		return fmt.Sprintf("$%d", paramIdx)
	}

	catParam := nextParam(catID)

	var whereClauses []string
	whereClauses = append(whereClauses, fmt.Sprintf("%s = ANY(category_ids)", catParam))

	for _, f := range req.Filters {
		clause, err := buildFilterClause(f, nextParam)
		if err != nil {
			return nil, fmt.Errorf("filter error: %w", err)
		}
		if clause != "" {
			whereClauses = append(whereClauses, clause)
		}
	}

	orderSQL := defaultOrderSQL
	if req.Sort != nil {
		orderSQL, err = buildSortClause(req.Sort)
		if err != nil {
			return nil, fmt.Errorf("sort error: %w", err)
		}
	}

	return &searchQuery{
		whereSQL: strings.Join(whereClauses, " AND "),
		orderSQL: orderSQL,
		params:   params,
	}, nil
}

const defaultOrderSQL = "product_name ASC, brand_name ASC, product_id ASC, variant_id ASC"

func (s *SearchService) executeCount(ctx context.Context, q *searchQuery) (int, error) {
	sql := fmt.Sprintf("SELECT COUNT(*) FROM search_product_variant WHERE %s", q.whereSQL)
	var count int
	if err := s.pool.QueryRow(ctx, sql, q.params...).Scan(&count); err != nil {
		return 0, fmt.Errorf("count query: %w", err)
	}
	return count, nil
}

func (s *SearchService) executeSearch(ctx context.Context, q *searchQuery, limit, offset int) ([]model.SearchRow, error) {
	// Append limit/offset params
	params := append([]interface{}{}, q.params...)
	limitIdx := len(params) + 1
	offsetIdx := len(params) + 2
	params = append(params, limit, offset)

	sql := fmt.Sprintf(`
		SELECT variant_id, product_id, product_name, variant_name,
		       brand_id, brand_name, primary_category_id,
		       number_attrs, bool_attrs, enum_attrs, string_attrs
		FROM search_product_variant
		WHERE %s
		ORDER BY %s
		LIMIT $%d OFFSET $%d
	`, q.whereSQL, q.orderSQL, limitIdx, offsetIdx)

	rows, err := s.pool.Query(ctx, sql, params...)
	if err != nil {
		return nil, fmt.Errorf("data query: %w", err)
	}
	defer rows.Close()

	return scanSearchRows(rows)
}

// rowScanner abstracts pgx.Rows for testability.
type rowScanner interface {
	Next() bool
	Scan(dest ...interface{}) error
	Err() error
}

func scanSearchRows(rows rowScanner) ([]model.SearchRow, error) {
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

		results = append(results, model.SearchRow{
			VariantID:         strconv.FormatInt(variantID, 10),
			ProductID:         strconv.FormatInt(productID, 10),
			ProductName:       productName,
			VariantName:       vn,
			BrandID:           strconv.FormatInt(brandID, 10),
			BrandName:         brandName,
			PrimaryCategoryID: strconv.FormatInt(primaryCatID, 10),
			Attributes:        buildAttributes(numberAttrs, boolAttrs, enumAttrs, strAttrs),
		})
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate rows: %w", err)
	}

	if results == nil {
		results = []model.SearchRow{}
	}
	return results, nil
}

// --- Filter builders ---

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

// --- Sort builder ---

func buildSortClause(sort *model.Sort) (string, error) {
	dir := "ASC"
	if sort.Direction == "desc" {
		dir = "DESC"
	}

	attrKey := sort.AttributeID
	return fmt.Sprintf(
		`(number_attrs->>'%s')::numeric %s NULLS LAST, `+
			`string_attrs->>'%s' %s NULLS LAST, `+
			`product_name ASC, brand_name ASC, product_id ASC, variant_id ASC`,
		attrKey, dir, attrKey, dir,
	), nil
}

// --- Attribute JSONB parser ---

func buildAttributes(numberRaw, boolRaw, enumRaw, strRaw json.RawMessage) map[string]model.AttributeValue {
	attrs := make(map[string]model.AttributeValue)

	parseNumberAttrs(numberRaw, attrs)
	parseBoolAttrs(boolRaw, attrs)
	parseEnumAttrs(enumRaw, attrs)
	parseStringAttrs(strRaw, attrs)

	return attrs
}

func parseNumberAttrs(raw json.RawMessage, out map[string]model.AttributeValue) {
	var m map[string]json.Number
	if err := json.Unmarshal(raw, &m); err != nil {
		return
	}
	for k, v := range m {
		if f, err := v.Float64(); err == nil {
			out[k] = model.AttributeValue{Type: "number", Value: f}
		}
	}
}

func parseBoolAttrs(raw json.RawMessage, out map[string]model.AttributeValue) {
	var m map[string]bool
	if err := json.Unmarshal(raw, &m); err != nil {
		return
	}
	for k, v := range m {
		out[k] = model.AttributeValue{Type: "bool", Value: v}
	}
}

func parseEnumAttrs(raw json.RawMessage, out map[string]model.AttributeValue) {
	var m map[string]json.Number
	if err := json.Unmarshal(raw, &m); err != nil {
		return
	}
	for k, v := range m {
		out[k] = model.AttributeValue{Type: "enum_list", Value: v.String()}
	}
}

func parseStringAttrs(raw json.RawMessage, out map[string]model.AttributeValue) {
	var m map[string]string
	if err := json.Unmarshal(raw, &m); err != nil {
		return
	}
	for k, v := range m {
		out[k] = model.AttributeValue{Type: "string", Value: v}
	}
}
