package model

// --- Search response ---

type SearchResponse struct {
	Rows       []SearchRow `json:"rows"`
	Pagination Pagination  `json:"pagination"`
}

type SearchRow struct {
	VariantID         string                       `json:"variantId"`
	ProductID         string                       `json:"productId"`
	ProductName       string                       `json:"productName"`
	VariantName       string                       `json:"variantName"`
	BrandID           string                       `json:"brandId"`
	BrandName         string                       `json:"brandName"`
	PrimaryCategoryID string                       `json:"primaryCategoryId"`
	Attributes        map[string]AttributeValue    `json:"attributes"`
}

type AttributeValue struct {
	Type  string      `json:"type"`
	Value interface{} `json:"value"`
}

type EnumValue struct {
	ID   string `json:"id"`
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type Pagination struct {
	Limit     int `json:"limit"`
	Offset    int `json:"offset"`
	TotalRows int `json:"totalRows"`
}

// --- Schema response ---

type SchemaResponse struct {
	Categories         []CategoryNode                    `json:"categories"`
	Attributes         map[string]AttributeDef           `json:"attributes"`
	CategoryAttributes map[string][]CategoryAttrEntry    `json:"categoryAttributes"`
}

type CategoryNode struct {
	ID       string         `json:"id"`
	Slug     string         `json:"slug"`
	Name     string         `json:"name"`
	Children []CategoryNode `json:"children"`
}

type AttributeDef struct {
	ID          string        `json:"id"`
	Slug        string        `json:"slug"`
	Name        string        `json:"name"`
	Type        string        `json:"type"`
	NumberUnit  string        `json:"numberUnit"`
	EnumOptions []EnumOption  `json:"enumOptions"`
}

type EnumOption struct {
	ID           string `json:"id"`
	Slug         string `json:"slug"`
	Name         string `json:"name"`
	DisplayOrder int    `json:"displayOrder"`
}

type CategoryAttrEntry struct {
	AttributeID string `json:"attributeId"`
	Priority    int    `json:"priority"`
}
