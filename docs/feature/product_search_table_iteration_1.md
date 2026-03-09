# Overview

- this feature revolves around improving the UI of the filters

# Task 1: enum filter drop downs

- enum type filters should be a dropdown menu with multi select available

# Task 2: group filters by type

- filters should be grouped by attirbute type, horizontally. within a group, the order should follow the same priority described in @docs/feature/product_search_table.md for displaying attributes in the actual product table

**Type ordering (decided):** `number` → `enum_list` → `bool` → `string`

Rationale:
- `number`: range inputs are the most analytical and widely used filter; shown first
- `enum_list`: categorical dropdowns are the next most common filter
- `bool`: simple yes/no toggles; less common
- `string`: exact-match inputs are the least common and most narrow; shown last

Within each group, attributes follow the same column priority: filtered attributes first, then ancestor category attributes (root-first), then selected category attributes, then descendant category attributes; within each category ordered by attribute priority then attribute id.

# Task 3: collapsing filters

- allow collapsing all filter options (NOT CATEGORY SELECTION) so that the user can just use only the table

# Task 4: clearer sections

- it should be clear to the user

1. where the filters start

2. where the filters end and the table begins

3. where one attirbute type's filters end and a new type's begin