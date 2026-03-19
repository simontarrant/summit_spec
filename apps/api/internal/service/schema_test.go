package service

import (
	"testing"

	"github.com/simontarrant/summit-spec/apps/api/internal/model"
)

func TestBuildCategoryTree_SingleRoot(t *testing.T) {
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
	}
	roots := buildCategoryTree(cats)
	if len(roots) != 1 {
		t.Fatalf("expected 1 root, got %d", len(roots))
	}
	if roots[0].ID != "1" || roots[0].Name != "Gear" {
		t.Errorf("unexpected root: %+v", roots[0])
	}
	if len(roots[0].Children) != 0 {
		t.Errorf("expected 0 children, got %d", len(roots[0].Children))
	}
}

func TestBuildCategoryTree_ParentChild(t *testing.T) {
	parentID := int64(1)
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
		{ID: 2, Slug: "sleep", Name: "Sleep", ParentID: &parentID},
	}
	roots := buildCategoryTree(cats)
	if len(roots) != 1 {
		t.Fatalf("expected 1 root, got %d", len(roots))
	}
	if len(roots[0].Children) != 1 {
		t.Fatalf("expected 1 child, got %d", len(roots[0].Children))
	}
	child := roots[0].Children[0]
	if child.ID != "2" || child.Slug != "sleep" {
		t.Errorf("unexpected child: %+v", child)
	}
}

func TestBuildCategoryTree_MultipleRoots(t *testing.T) {
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
		{ID: 2, Slug: "food", Name: "Food", ParentID: nil},
	}
	roots := buildCategoryTree(cats)
	if len(roots) != 2 {
		t.Fatalf("expected 2 roots, got %d", len(roots))
	}
}

func TestBuildCategoryTree_ThreeLevels(t *testing.T) {
	p1 := int64(1)
	p2 := int64(2)
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
		{ID: 2, Slug: "sleep", Name: "Sleep", ParentID: &p1},
		{ID: 3, Slug: "pads", Name: "Pads", ParentID: &p2},
	}
	roots := buildCategoryTree(cats)
	if len(roots) != 1 {
		t.Fatalf("expected 1 root, got %d", len(roots))
	}
	if len(roots[0].Children) != 1 {
		t.Fatalf("root should have 1 child, got %d", len(roots[0].Children))
	}
	child := roots[0].Children[0]
	if len(child.Children) != 1 {
		t.Fatalf("child should have 1 grandchild, got %d", len(child.Children))
	}
	if child.Children[0].ID != "3" {
		t.Errorf("unexpected grandchild: %+v", child.Children[0])
	}
}

func TestBuildCategoryTree_OrphanBecomesRoot(t *testing.T) {
	// Parent ID 999 doesn't exist — orphan should become a root
	missingParent := int64(999)
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
		{ID: 5, Slug: "orphan", Name: "Orphan", ParentID: &missingParent},
	}
	roots := buildCategoryTree(cats)
	if len(roots) != 2 {
		t.Fatalf("expected 2 roots (including orphan), got %d", len(roots))
	}
}

func TestBuildCategoryTree_Empty(t *testing.T) {
	roots := buildCategoryTree(nil)
	if roots != nil && len(roots) != 0 {
		t.Errorf("expected nil or empty, got %d roots", len(roots))
	}
}

func TestBuildCategoryTree_ChildrenInitialized(t *testing.T) {
	cats := []catRow{
		{ID: 1, Slug: "gear", Name: "Gear", ParentID: nil},
	}
	roots := buildCategoryTree(cats)
	// Children should be an empty slice, not nil (for JSON serialization)
	if roots[0].Children == nil {
		t.Error("Children should be initialized to empty slice, not nil")
	}
}

// --- buildAttributeMaps ---

func TestBuildAttributeMaps_Basic(t *testing.T) {
	rows := []catAttrRow{
		{CatID: 1, AttrFK: 5, Priority: 100, AttrID: 5, Slug: "weight", Name: "Weight", AttrType: "number", NumberUnit: "weight_g"},
		{CatID: 1, AttrFK: 6, Priority: 90, AttrID: 6, Slug: "insulated", Name: "Insulated", AttrType: "bool", NumberUnit: "NA"},
	}

	attrs, catAttrs, enumIDs := buildAttributeMaps(rows)

	if len(attrs) != 2 {
		t.Fatalf("expected 2 attributes, got %d", len(attrs))
	}
	if attrs["5"].Slug != "weight" || attrs["5"].Type != "number" {
		t.Errorf("unexpected attr 5: %+v", attrs["5"])
	}
	if attrs["6"].Slug != "insulated" || attrs["6"].Type != "bool" {
		t.Errorf("unexpected attr 6: %+v", attrs["6"])
	}

	if len(catAttrs["1"]) != 2 {
		t.Fatalf("expected 2 category_attributes for cat 1, got %d", len(catAttrs["1"]))
	}

	if len(enumIDs) != 0 {
		t.Errorf("expected no enum attr IDs, got %v", enumIDs)
	}
}

func TestBuildAttributeMaps_DeduplicatesAttributes(t *testing.T) {
	// Same attribute appears under two categories
	rows := []catAttrRow{
		{CatID: 1, AttrFK: 5, Priority: 100, AttrID: 5, Slug: "weight", Name: "Weight", AttrType: "number", NumberUnit: "weight_g"},
		{CatID: 2, AttrFK: 5, Priority: 80, AttrID: 5, Slug: "weight", Name: "Weight", AttrType: "number", NumberUnit: "weight_g"},
	}

	attrs, catAttrs, _ := buildAttributeMaps(rows)

	if len(attrs) != 1 {
		t.Fatalf("expected 1 deduplicated attribute, got %d", len(attrs))
	}
	if len(catAttrs["1"]) != 1 || len(catAttrs["2"]) != 1 {
		t.Errorf("expected 1 entry per category, got cat1=%d cat2=%d", len(catAttrs["1"]), len(catAttrs["2"]))
	}
}

func TestBuildAttributeMaps_CollectsEnumIDs(t *testing.T) {
	rows := []catAttrRow{
		{CatID: 1, AttrFK: 7, Priority: 50, AttrID: 7, Slug: "pad-type", Name: "Pad Type", AttrType: "enum_list", NumberUnit: "NA"},
	}

	_, _, enumIDs := buildAttributeMaps(rows)

	if len(enumIDs) != 1 || enumIDs[0] != 7 {
		t.Errorf("expected [7], got %v", enumIDs)
	}
}

func TestBuildAttributeMaps_Empty(t *testing.T) {
	attrs, catAttrs, enumIDs := buildAttributeMaps(nil)
	if len(attrs) != 0 || len(catAttrs) != 0 || len(enumIDs) != 0 {
		t.Error("expected all empty maps for nil input")
	}
}

// helper to find a category by ID in roots
func findCategory(roots []model.CategoryNode, id string) *model.CategoryNode {
	for i := range roots {
		if roots[i].ID == id {
			return &roots[i]
		}
		if found := findCategory(roots[i].Children, id); found != nil {
			return found
		}
	}
	return nil
}
