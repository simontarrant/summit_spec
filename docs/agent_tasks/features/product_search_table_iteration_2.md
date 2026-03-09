# Task 1: attribute priority of parent category

- when the category selected is a child category with a parent, previously the logic is to place the parent attributes with higher priority

- but this is not desirable, parent categories of the selected caegory should have equal prriority with the selected category. both the selected category and the parent categories will still have higher priority than child categories of the selected category

- tie break between parent and selected categories with the usual priority ranking

- see docs/feature/product_search_table.md for the original priority implementation