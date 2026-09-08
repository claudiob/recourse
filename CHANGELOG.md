# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## 4.4.0 - 2026-09-08

* [Fix] Tapping the light/dark toggle or the log out on a phone leaves no tint behind
* [Feature] On a phone a resource's breadcrumb is its icon alone, leaving the row to the search box and the button
* [Feature] On a phone a card's tabs are their icons and figures: Show and Edit their
  icons, a counted tab its icon and its number
* [Feature] On a phone the whole `Franchises: 21` of a stacked counter cell is the link
* [Fix] A touch screen shows no tooltips, a tap being what would open the link beneath one
* [Fix] Safari no longer zooms in on the search box or a filter: the controls are 16px on a phone, where the body itself is 14
* [Fix] A sidebar link tapped on a phone leaves no hover tint on it or on the link the next page puts under the finger

## 4.3.0 - 2026-09-08

* [Feature] On a phone a stacked cell reads as one line, `Estimate hi: 600`
* [Feature] On a phone the sidebar's icons carry their words: `Dark mode`, `Light mode`, `Exit`
* [Fix] A page never scrolls sideways on a phone, and Safari no longer zooms out of it

  Safari laid the stacked table's hidden header row out at its full width; the page
  now clips what would run past the window.

* [Fix] Safari no longer zooms in on the search box or a filter when it is focused

  The small controls were 14px, and Safari zooms on any field under 16; on a phone
  they take the body's size.

* [Fix] The footer's sentence stands above the pages on a phone rather than beside them
* [Fix] A filter's menu drops over the first rows of the table rather than under them
* [Feature] A date or a time is headed `Created` and `Updated`, not `Created at` and `Updated at`
* [Fix] A touch screen gets no hover tint on a table's rows

## 4.2.0 - 2026-09-08

* [Feature] The log-out button sits beside the light/dark toggle

  The two share the sidebar's foot, each centered in its own half, and a hover tints
  either under a rounded corner.

* [Fix] A bookmark click no longer marks the row green
* [Fix] The log-out button is submitted by the browser, not by Turbo

  A log out ends with a redirect to wherever the host signs people in, which is
  another origin a fetch cannot follow, so the click left the page where it was.

  The kept tint taking or leaving is the whole report.

## 4.1.2 - 2026-09-08

* [Fix] The engine requires turbo-rails after Rails, not before

  4.1.1 required it as the gem loaded, which broke an app loading the gem ahead of
  Rails: Turbo's engine wants Action Dispatch as it is defined.

## 4.1.1 - 2026-09-08

* [Fix] The engine requires turbo-rails itself

  Bundler requires the gems a host's Gemfile names and not their dependencies, so a
  host listing only `recourse` booted into `uninitialized constant Turbo`.

## 4.1.0 - 2026-09-08

* [Feature] Rows with nothing in the sorted column come last

  Whichever way a table is ordered — by the model's own `recourse_order`, or by the
  heading a reader clicked — the rows with nothing in that column now come after every
  row that has something, where the database's default put them first on a descending
  sort. A `recourse_order` given as a Symbol or a Hash earns this; a SQL string a host
  wrote is still taken as written, so `'size desc nulls last'` and `{ size: :desc }` now
  say the same thing.

## 4.0.0 - 2026-09-08

Version 4 is a rewrite, developed under the working name `drive` and released here
because it is the same library: the module is still `Recourse` and the entry point is
still one word in `config/routes.rb`.

Version 3 drew the routes and served one screen — a paginated, searchable index — and
left the controller, the other six actions and every form to the host app. Version 4
serves all seven, defines the controllers itself, and works out what each screen should
look like by reading the model: its validators, its associations, its column types and
its indexes. Most of what a host used to override is now something it no longer writes.

* [BREAKING CHANGE] Rails 8.1 and Ruby 3.2 are the minimum; so are Pagy 43 and Ransack 4.4
* [BREAKING CHANGE] `recourses` defines the controller as well as the routes

  A host no longer writes `class PostsController < RecoursesController` for each
  resource. The controller is defined as the route is drawn, and a host that wants one
  of its own still writes it — the gem only fills the gap. `RecoursesController`
  changes meaning with that: it is no longer the class each resource subclasses but the
  one they all inherit, and a host defines it — `class RecoursesController <
  Recourse::BaseController` — to put a `before_action` above every screen at once.

* [BREAKING CHANGE] `search_field`, `search_prompt` and `searchable_fields` are no
  longer yours to define

  The search box looks through every indexed string column the table shows, plus the
  label behind a foreign key too long to list, and says so in its own placeholder.

* [BREAKING CHANGE] The Ransack hooks default to something instead of to nothing

  `ransackable_attributes`, `ransackable_associations`, `ransortable_attributes` and
  `filter_fields` are still yours to override, but a model that says nothing is now
  fully searchable, sortable and filterable: a column is sortable when an index covers
  it, an enum and a boolean earn a filter, and so does each `belongs_to`.

* [BREAKING CHANGE] A `filter_fields` entry is keyed by the predicate and carries its
  options: `{ 'state_id_in' => { label: 'Home state' } }`
* [BREAKING CHANGE] `recourse_searchable?`, `recourse_sortable?`, `recourse_cachable?`
  and `recourse_timestamps` are gone

  The first two follow from the indexes. The table is a fragment keyed on the
  relation, so caching needs no switch. `recourse_displayed` names a timestamp back.

* [BREAKING CHANGE] `Recourse.resources`, `navigation_links` and `NavigableHelper` are gone

  The gem draws its own sidebar from the resources `recourses` declared. An icon comes
  from the `unicon` gem, named by `recourse_icon`, which defaults to the model's name.

* [BREAKING CHANGE] `search_highlight` takes the column, not the model:
  `search_highlight(post.content, :content)`
* [BREAKING CHANGE] A row partial sorts with `sort_header`, not Ransack's `sort_link`
* [BREAKING CHANGE] A row reads in the order its columns' kinds earn — state, keys,
  words, flags, long values, dates, timestamps, counts — and the schema's order inside each
* [BREAKING CHANGE] A link reads as its host rather than as the whole address
* [Feature] Every action is served: index, show, new, create, edit, update and destroy
* [Feature] A form field is chosen to suit each column, and carries the rules the
  model's validators state — a length becomes a `maxlength`, a format becomes a
  `pattern`, a numericality becomes a numeric keyboard
* [Feature] An enum becomes a badge on a page and a menu in a form; a foreign key
  becomes a menu of the records it points at, or a field to type into where there are
  too many to list — and a typed label naming two rows is refused rather than guessed at
* [Feature] Values are formatted by what the column holds: delimited integers, money,
  phone numbers, a month by its name, a URL as a link, JSON as JSON, a list as a count
  that opens, and a timestamp in the reader's own time zone saying how long ago
* [Feature] Nested resources are drawn as tabs on the parent's card, counted where a
  counter cache exists; a nested `create` with no index is a button on the parent
* [Feature] Active Record Encryption is respected throughout: an encrypted column never
  reaches a table, arrives masked on a record's own page behind a `Show`, and is offered
  in the clear on the form that edits it
* [Feature] A viewer keeps a row: `Recourse.bookmarks` names the viewer's rows, and every
  table that can hold one opens with a square, kept rows first
* [Feature] A route named `exit` gives the sidebar a log-out button
* [Feature] Turbo drives the screens — frames, live refreshes of an open index when a row
  changes, a delete that names what goes with it before it goes, and the row a write
  landed on marked
* [Feature] A reader picks how many rows a page shows, and whether the page is light or dark
* [Feature] Bootstrap 6 and Bootstrap Icons are vendored and served by the engine, so a
  host with no asset pipeline and no CDN still gets styled screens
* [Feature] `Recourse.color = :purple` restyles every screen at once
* [Feature] Model hooks: `recourse_label`, `recourse_hidden`, `recourse_displayed`,
  `recourse_order`, `recourse_icon`, `recourse_includes`, `recourse_comment` and
  `recourse_broadcasts?`
* [Feature] Every string the gem shows is a key in `config/locales/recourse.en.yml`

## 3.0.4 - 2026-07-24

* [Feature] Add "Inquiries" icon

## 3.0.3 - 2026-07-24

* [Feature] Add "Agents" icon

## 3.0.2 - 2026-07-23

* [Feature] Add "Contacts" icon

## 3.0.1 - 2026-07-22

* [Feature] Add searchable_fields to models

## 3.0.0 - 2026-07-22

* [BREAKING CHANGE] Replace single filter_field with multiple filter_fields

## 2.0.2 - 2026-07-20

* [Feature] Add "Contract", "Profile", "CRM" icons

## 2.0.1 - 2026-07-13

* [Fix] Improve search bar responsiveness

## 2.0.0 - 2026-07-13

* [BREAKING CHANGE] Restyle table and search field to take advantage of Bootstrap 6

## 1.4.6 - 2026-07-10

* [Feature] Replace "Benches" with "Markets" icons

## 1.4.5 - 2026-06-24

* [Feature] Add "Benches" icons

## 1.4.4 - 2026-06-24

* [Feature] Add "Platforms" icons

## 1.4.3 - 2026-06-24

* [Feature] Add "Brands" icons

## 1.4.2 - 2026-06-24

* [Feature] Add common recourse icons
* [Feature] Add common acronyms, e.g.: API, CRM, ZIP

## 1.4.1 - 2026-06-23

* [Fix] Remove deprecated LookupContext.find_template!

## 1.4.0 - 2026-06-23

* [Feature] Add navigation_links method

## 1.3.5 - 2026-05-15

* [Feature] Display pagy info with number delimiters

## 1.3.3 - 2026-04-09

* [Fix] Allow for nested resources not defined at the root level

## 1.3.2 - 2026-04-09

* Temporarily disable caching

## 1.3.1 - 2026-04-06

* [Fix] Use a different caching key based on the controller path

Posts could be displayed differently under /users/:id/posts or under /topics/:id/posts
so they should be cached separately.

## 1.3.0 - 2026-04-03

* [BREAKING CHANGE] Rename `search_placeholder` to `search_prompt`

## 1.2.0 - 2026-03-31

* [BREAKING CHANGE] `RecourseController` is now `RecoursesController`
* [BREAKING CHANGE] "Add" button is now yield in the `content_for :actions`
* [BREAKING CHANGE] `recourse_positionable?` is no longer supported
* [Deprecation] `header:` parameter is no longer required in `column`.
* [Feature] support for nested resources
* [Feature] support for ransack searches

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


