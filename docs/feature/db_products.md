# Background

Products have a primary category, and may also have zero or more secondary categories. Categories have attributes. Categories may have parent attributes. Concrete products then have attirbute values for the attirbutes related to the categories it belongs to. Where a product belongs to category that has a parent category, it should have the attributes of both the parent and the child. In this way, the attirbutes of parent categories are inherited to child category products.

IGNORE SUBJECTIVE ATTIRBUTES FOR NOW

# Task

1. Implement the BE api

   - The FE needs to know about both the category schemas AND the concrete products
   - For category schemas, there needs to be some way for the BE to fetch from the db:
     - available categories
     - what attributes apply to those categories
     - parent/hierarchical relationship between the categories
   - For concrete products, based on the user's query filters (based on info selected from the category schemas):
     - Relevant products
     - with correct sorting according to inputs
     - with pagination strategy implemented

2. Implement the FE

    - This can be done with classic FE api calls or servers components, can be discussed in planning
    - The FE needs display a table
      - The table should have options the user can select
        - category selection (should display that category and all children)
        - filters
          - for all available attributes for the category selected, the user should be able to use them to filter the results
            - Judgement should be used to ensure the filter method is appropriate for the attribute type
        - Sorting
          - user should be able to sort the results based on any available attribute where the type logically supports sorting
        - The table should display as many rows as user's display can fit in single row reasonably
          - Where there are more attirbutes than can fit on user's display, from left to right, show attirbutes of parent categories first. Priority for attributes within a category should be based on the 'priority' of that attribute for the category (alpha if tied)
        - Missing product attribute values, by default exclude for filtering, place at bottom priority for sorting, allow option to include missing for filtering