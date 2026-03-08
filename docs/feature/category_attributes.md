# DONE - implemented

# Background

- Currently products belong to categories. Products have attributes. Thus it may be possible ot derive a category's attirbutes from the products' attributes. But we don't want to do this. we want to define categories as having a set of attributes. 

# Task

- add a relation table between category and attribute
  - also, product_attributes should now foreign key link to this new relation, not the raw attirbute. this will allow us to migrate in future if changing categories
- Update seed data to reflect this

# Details

- a child category shouldn't have the same attribute as a parent attribute. keep this in mind for seed data. In future we will have app logic that will prevent this for real data
