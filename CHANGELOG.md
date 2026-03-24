# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## 1.1.0 - 2026-03-24

* [BREAKING CHANGE] `recourses` only accepts one resource if a block is provided
* [BREAKING CHANGE] `recourses` automatically sets the module for nested resources

Before this change this config/routes.rb was valid:

```ruby
recourses(:users, :posts) { resources :comments }
```

and followed Rails `resources` behavior of creating **two** nested resources: `users/comments` and
`posts/comments`. After this change, each base resource needs to be defined separately:

```ruby
recourses(:users) { resources :comments }
recourses(:posts) { resources :comments }
```

This syntax is more explicit and allows nested resources to be defined under the parent's module.
In other words, the previous code is equivalent to:

```ruby
resources(:users) { resources :comments, module: :users }
resources(:posts) { resources :comments, module: :posts }
```

which allows developers to have two different controllers/actions to display a user comments
(/users/:id/comments) or to display a post comments (/posts/:id/comments)

## 1.0.2 - 2026-03-23

* [BUG] Avoid Zeitweirk conflict when loading Active Record

## 1.0.1 - 2026-03-10

* [BUG] Only show search form when search attributes are present

## 1.0.0 - 2026-03-10

* [FEATURE] New `recourses` method that can be invoked inside config/routes.rb

`recourses` is like `resources` on steroids for admin-only routes:

- All the routes are included in `Recourse.resources` to easily display in a navbar
- Their controllers do not need to define the `index` action: they inherit a predefined one
- There is also a predefined `index.html` view which displays the resources paginated/searchable.
- The content of each row can be customized defining a new `_row.html.erb` partial


