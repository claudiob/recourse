Recourse
========

Provides a new `recourses` method that can be invoked in a Rails app inside config/routes.rb

`recourses` is like `resources` on steroids for admin-only routes:

- All the routes are included in `Recourse.resources` to easily display in a navbar
- Their controllers do not need to define the `index` action: they inherit a predefined one
- There is also a predefined `index.html` view which displays the resources paginated/searchable.
- The content of each row can be customized defining a new `_row.html.erb` partial

How to install
==============

1. Add `gem 'resource'` to the `Gemfile` file of your Rails app.

Available methods
=================

In config/routes.rb:

- `recourses` inside the routes

In a resourceful Active Record model:

- `recourse_includes`: the associations to include when fetching the resources
- `recourse_order`: the SQL to sort the resources by
- `recourse_positionable?`: whether the model has a position field to drag'n'drop sort

Anywhere:

- `Recourse.resources` to list all the routes

