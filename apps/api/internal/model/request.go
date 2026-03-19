package model

import "encoding/json"

type SearchRequest struct {
	CategoryID string   `json:"categoryId"`
	Filters    []Filter `json:"filters"`
	Sort       *Sort    `json:"sort"`
	Limit      int      `json:"limit"`
	Offset     int      `json:"offset"`
}

type Sort struct {
	AttributeID string `json:"attributeId"`
	Direction   string `json:"direction"` // "asc" or "desc"
}

type Filter struct {
	AttributeID string          `json:"attributeId"`
	Type        string          `json:"type"` // "number", "bool", "enum_list", "string"
	Operator    string          `json:"operator,omitempty"`
	Value       json.RawMessage `json:"value"`
}
