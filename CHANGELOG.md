# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## 1.0.0 - 2026-03-10

* [FEATURE] New `recourses` method that can be invoked inside config/routes.rb

`recourses` is like `resources` on steroids for admin-only routes:

- All the routes are included in `Recourse.resources` to easily display in a navbar
- Their controllers do not need to define the `index` action: they inherit a predefined one
- There is also a predefined `index.html` view which displays the resources paginated/searchable.
- The content of each row can be customized defining a new `_row.html.erb` partial


