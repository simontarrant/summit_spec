package service

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/simontarrant/summit-spec/apps/api/internal/model"
)

// --- normalizeRequest ---

func TestNormalizeRequest_Defaults(t *testing.T) {
	req := normalizeRequest(model.SearchRequest{})
	if req.Limit != 25 {
		t.Errorf("expected limit 25, got %d", req.Limit)
	}
	if req.Offset != 0 {
		t.Errorf("expected offset 0, got %d", req.Offset)
	}
}

func TestNormalizeRequest_ClampLimit(t *testing.T) {
	req := normalizeRequest(model.SearchRequest{Limit: 200})
	if req.Limit != 25 {
		t.Errorf("expected limit 25 for over-max, got %d", req.Limit)
	}

	req = normalizeRequest(model.SearchRequest{Limit: -1})
	if req.Limit != 25 {
		t.Errorf("expected limit 25 for negative, got %d", req.Limit)
	}
}

func TestNormalizeRequest_ClampOffset(t *testing.T) {
	req := normalizeRequest(model.SearchRequest{Limit: 10, Offset: -5})
	if req.Offset != 0 {
		t.Errorf("expected offset 0 for negative, got %d", req.Offset)
	}
}

func TestNormalizeRequest_PreservesValid(t *testing.T) {
	req := normalizeRequest(model.SearchRequest{Limit: 50, Offset: 10})
	if req.Limit != 50 || req.Offset != 10 {
		t.Errorf("expected limit=50 offset=10, got limit=%d offset=%d", req.Limit, req.Offset)
	}
}

// --- buildSearchQuery ---

func TestBuildSearchQuery_InvalidCategoryID(t *testing.T) {
	_, err := buildSearchQuery(model.SearchRequest{CategoryID: "abc"})
	if err == nil {
		t.Fatal("expected error for non-numeric categoryId")
	}
}

func TestBuildSearchQuery_BasicCategory(t *testing.T) {
	q, err := buildSearchQuery(model.SearchRequest{CategoryID: "1"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(q.whereSQL, "ANY(category_ids)") {
		t.Errorf("WHERE should contain category filter, got: %s", q.whereSQL)
	}
	if q.orderSQL != defaultOrderSQL {
		t.Errorf("expected default order, got: %s", q.orderSQL)
	}
	if len(q.params) != 1 {
		t.Errorf("expected 1 param, got %d", len(q.params))
	}
}

func TestBuildSearchQuery_WithSort(t *testing.T) {
	q, err := buildSearchQuery(model.SearchRequest{
		CategoryID: "1",
		Sort:       &model.Sort{AttributeID: "5", Direction: "desc"},
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(q.orderSQL, "DESC") {
		t.Errorf("order should contain DESC, got: %s", q.orderSQL)
	}
}

func TestBuildSearchQuery_WithFilters(t *testing.T) {
	q, err := buildSearchQuery(model.SearchRequest{
		CategoryID: "1",
		Filters: []model.Filter{
			{AttributeID: "5", Type: "number", Operator: "gte", Value: json.RawMessage(`100`)},
		},
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(q.whereSQL, "number_attrs") {
		t.Errorf("WHERE should contain number_attrs filter, got: %s", q.whereSQL)
	}
	if len(q.params) != 2 { // catID + filter value
		t.Errorf("expected 2 params, got %d", len(q.params))
	}
}

// --- buildFilterClause ---

func newNextParam() func(interface{}) string {
	idx := 0
	return func(v interface{}) string {
		idx++
		return "$" + strings.Repeat("x", idx) // deterministic placeholder
	}
}

func TestBuildFilterClause_Number_GTE(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "gte", Value: json.RawMessage(`3.5`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "number_attrs") || !strings.Contains(clause, ">=") {
		t.Errorf("expected number_attrs >= clause, got: %s", clause)
	}
}

func TestBuildFilterClause_Number_LTE(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "lte", Value: json.RawMessage(`100`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "<=") {
		t.Errorf("expected <= in clause, got: %s", clause)
	}
}

func TestBuildFilterClause_Number_EQ(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "eq", Value: json.RawMessage(`42`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "= ") {
		t.Errorf("expected = in clause, got: %s", clause)
	}
}

func TestBuildFilterClause_Number_Between(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "between", Value: json.RawMessage(`[10, 50]`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, ">=") || !strings.Contains(clause, "<=") {
		t.Errorf("expected >= and <= in clause, got: %s", clause)
	}
}

func TestBuildFilterClause_Number_DefaultOperator(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Value: json.RawMessage(`10`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, ">=") {
		t.Errorf("expected default gte operator, got: %s", clause)
	}
}

func TestBuildFilterClause_Number_InvalidValue(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "gte", Value: json.RawMessage(`"notanumber"`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for string value in number filter")
	}
}

func TestBuildFilterClause_Number_UnknownOperator(t *testing.T) {
	f := model.Filter{AttributeID: "5", Type: "number", Operator: "like", Value: json.RawMessage(`1`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for unknown operator")
	}
}

func TestBuildFilterClause_Bool(t *testing.T) {
	f := model.Filter{AttributeID: "6", Type: "bool", Value: json.RawMessage(`true`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "bool_attrs") || !strings.Contains(clause, "boolean") {
		t.Errorf("expected bool_attrs clause, got: %s", clause)
	}
}

func TestBuildFilterClause_Bool_InvalidValue(t *testing.T) {
	f := model.Filter{AttributeID: "6", Type: "bool", Value: json.RawMessage(`"yes"`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for non-bool value")
	}
}

func TestBuildFilterClause_EnumList(t *testing.T) {
	f := model.Filter{AttributeID: "7", Type: "enum_list", Value: json.RawMessage(`["1","2"]`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "enum_attrs") || !strings.Contains(clause, "ANY") {
		t.Errorf("expected enum_attrs ANY clause, got: %s", clause)
	}
}

func TestBuildFilterClause_EnumList_Empty(t *testing.T) {
	f := model.Filter{AttributeID: "7", Type: "enum_list", Value: json.RawMessage(`[]`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for empty enum list")
	}
}

func TestBuildFilterClause_EnumList_InvalidID(t *testing.T) {
	f := model.Filter{AttributeID: "7", Type: "enum_list", Value: json.RawMessage(`["abc"]`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for non-numeric enum ID")
	}
}

func TestBuildFilterClause_String(t *testing.T) {
	f := model.Filter{AttributeID: "8", Type: "string", Value: json.RawMessage(`"hello"`)}
	clause, err := buildFilterClause(f, newNextParam())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "string_attrs") {
		t.Errorf("expected string_attrs clause, got: %s", clause)
	}
}

func TestBuildFilterClause_UnknownType(t *testing.T) {
	f := model.Filter{AttributeID: "9", Type: "json", Value: json.RawMessage(`{}`)}
	_, err := buildFilterClause(f, newNextParam())
	if err == nil {
		t.Fatal("expected error for unknown filter type")
	}
}

// --- buildSortClause ---

func TestBuildSortClause_ASC(t *testing.T) {
	clause, err := buildSortClause(&model.Sort{AttributeID: "5", Direction: "asc"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "ASC NULLS LAST") {
		t.Errorf("expected ASC NULLS LAST, got: %s", clause)
	}
	if strings.Contains(clause, "DESC") {
		t.Errorf("should not contain DESC, got: %s", clause)
	}
}

func TestBuildSortClause_DESC(t *testing.T) {
	clause, err := buildSortClause(&model.Sort{AttributeID: "5", Direction: "desc"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(clause, "DESC NULLS LAST") {
		t.Errorf("expected DESC NULLS LAST, got: %s", clause)
	}
}

func TestBuildSortClause_IncludesDefaultTiebreakers(t *testing.T) {
	clause, _ := buildSortClause(&model.Sort{AttributeID: "5", Direction: "asc"})
	if !strings.Contains(clause, "product_name ASC") {
		t.Errorf("expected tiebreaker in sort clause, got: %s", clause)
	}
}

// --- buildAttributes ---

func TestBuildAttributes_AllTypes(t *testing.T) {
	numberRaw := json.RawMessage(`{"5": 350.5}`)
	boolRaw := json.RawMessage(`{"6": true}`)
	enumRaw := json.RawMessage(`{"7": 42}`)
	strRaw := json.RawMessage(`{"8": "ultralight"}`)

	attrs := buildAttributes(numberRaw, boolRaw, enumRaw, strRaw)

	if len(attrs) != 4 {
		t.Fatalf("expected 4 attributes, got %d", len(attrs))
	}

	// Number
	if attrs["5"].Type != "number" {
		t.Errorf("attr 5 type: expected number, got %s", attrs["5"].Type)
	}
	if attrs["5"].Value != 350.5 {
		t.Errorf("attr 5 value: expected 350.5, got %v", attrs["5"].Value)
	}

	// Bool
	if attrs["6"].Type != "bool" {
		t.Errorf("attr 6 type: expected bool, got %s", attrs["6"].Type)
	}
	if attrs["6"].Value != true {
		t.Errorf("attr 6 value: expected true, got %v", attrs["6"].Value)
	}

	// Enum
	if attrs["7"].Type != "enum_list" {
		t.Errorf("attr 7 type: expected enum_list, got %s", attrs["7"].Type)
	}
	if attrs["7"].Value != "42" {
		t.Errorf("attr 7 value: expected '42', got %v", attrs["7"].Value)
	}

	// String
	if attrs["8"].Type != "string" {
		t.Errorf("attr 8 type: expected string, got %s", attrs["8"].Type)
	}
	if attrs["8"].Value != "ultralight" {
		t.Errorf("attr 8 value: expected 'ultralight', got %v", attrs["8"].Value)
	}
}

func TestBuildAttributes_EmptyJSONB(t *testing.T) {
	attrs := buildAttributes(
		json.RawMessage(`{}`),
		json.RawMessage(`{}`),
		json.RawMessage(`{}`),
		json.RawMessage(`{}`),
	)
	if len(attrs) != 0 {
		t.Errorf("expected 0 attributes, got %d", len(attrs))
	}
}

func TestBuildAttributes_InvalidJSON(t *testing.T) {
	// Should not panic — silently skips unparseable data
	attrs := buildAttributes(
		json.RawMessage(`invalid`),
		json.RawMessage(`null`),
		json.RawMessage(`"notanobject"`),
		json.RawMessage(`[]`),
	)
	if len(attrs) != 0 {
		t.Errorf("expected 0 attributes for invalid JSON, got %d", len(attrs))
	}
}

func TestBuildAttributes_MultipleNumbers(t *testing.T) {
	attrs := buildAttributes(
		json.RawMessage(`{"1": 100, "2": 200.5, "3": 0}`),
		json.RawMessage(`{}`),
		json.RawMessage(`{}`),
		json.RawMessage(`{}`),
	)
	if len(attrs) != 3 {
		t.Fatalf("expected 3, got %d", len(attrs))
	}
	if attrs["3"].Value != float64(0) {
		t.Errorf("expected 0, got %v", attrs["3"].Value)
	}
}
