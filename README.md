# Recourse

Swap two characters in your `config/routes.rb` and get awesome admin screens for your Rails app.

This README is the tour. The [guides](https://claudiob.github.io/recourse/guides/) are
where every screen is explained in full, one page each, and the
[reference](https://rubydoc.info/gems/recourse) is built from the source.

## How to install

```bash
gem install recourse
```

```ruby
# Gemfile
gem 'recourse', '~> 7.0'
```

`~> 7.0` follows Semantic Versioning: `bundle update` takes every 7.x and never a
breaking change. Rails 8.1 and Ruby 3.2 are the minimum; the pages need Turbo, which
`turbo-rails` brings, and nothing else in the host. Everything a page is styled and
scripted by — Bootstrap 6, its icons, Turbo, Stimulus and the controllers behind these
screens — is `bh`, which this gem depends on and whose engine serves them at `/bh/`, so a
host without an asset pipeline gets the same screens and nothing is fetched across a
network.

## Step 1. Edit your routes

This is as easy as replacing any call to `resources` to use [`recourses`](https://rubydoc.info/gems/recourse/Recourse/Routes#recourses-instance_method) instead:

```diff
- resources :posts, only: %i[ index show ] do
+ recourses :posts, only: %i[ index show ] do
-   resources :comments, except: :destroy
+   recourses :comments, except: :destroy
end
```

Every recourse with `index` gets a sidebar entry (in routes order), a keyboard shortcut on its
first letter, and a paginated, searchable, sortable, filterable index table:

<img width="3824" height="2274" alt="Image" src="https://github.com/user-attachments/assets/f952d3e5-c320-464b-b166-77c7ab8f9071" />

Every recourse with `show` gets a detail page where attributes are displayed with the appropriate
formatting — a boolean as `Yes` or `No`, a date by its name, a key as the label of what it
points at — or masked if sensitive:

<img width="3824" height="2274" alt="Image" src="https://github.com/user-attachments/assets/515f63c4-8a9b-422e-95c4-88d6647911d8" />

Every recourse with `new` or `edit` gets a form with appropriate browser formatting and validation:

<img width="3824" height="1220" alt="Image" src="https://github.com/user-attachments/assets/ebe5108b-bbd1-4cd1-a635-89eef0e6fc50" />

Every recourse with `destroy` gets a button with a detailed confirmation message — on the
record's own page, whichever of `show` and `edit` is open, and on each row of its table
where no `edit` page would carry it. A row a model will not give up stays, and the page says so
rather than raising. A model may word its own deletion — `Disconnect` rather than
`Delete` — by writing `recourse.models.<model>.delete` in its locale:

[image]

Every nested recourse gets namespaced after the parent, and a tab on the parent's card:

<img width="3824" height="2274" alt="Image" src="https://github.com/user-attachments/assets/9b242335-a25b-4fa8-8023-422538d235b0" />

`recourse` draws what Rails' `resource` draws: one record reached with no id of its own,
at `/locations/5/property`, read off the parent under the name the route gives —
`location.property`, whether the parent keeps it with a `has_one` or points at one with
a `belongs_to`. What such a nesting earns on the parent's card depends only on what it
routes: a tab where `show` is, and a button beside the breadcrumb — `Add property`,
`Delete property` — where `create` or `destroy` is routed with no page of its own. A
singular resource holds at most one, so `new` sends a reader to the record where there
already is one, and `show` sends them to the form where there is none yet.

Two keywords say what a table may do beyond the seven actions. `positionable: true`
draws the route a dragged row reports its place to, and `retrievable: true` draws the
one a `Retrieve` button on the table posts to, for rows that came from somewhere else.
Both are refused on a resource with no `index`, since there is nowhere for either to
stand. The [routes guide](https://claudiob.github.io/recourse/guides/routes.html) has
the rest: namespaces, the defaults a nested resource takes, and the `enter` and `exit`
routes that earn the sidebar a sign-in link and a log-out button.

## Step 2. Enhance your models

To change what a model's screens show, override any of these class methods:

| Hook | Default | Decides |
| --- | --- | --- |
| [`recourse_label`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_label-instance_method) | `:name` | the column a combobox shows and a foreign-key cell reads; typed rather than picked where it has a length validator |
| [`recourse_hidden`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_hidden-instance_method) | `[]` | columns kept off the table, the page, the form and the search |
| [`recourse_order`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_order-instance_method) | `:id`, or the positioned column | the index's order, a Symbol or a Hash; rows with nothing in the column come last |
| [`recourse_position`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_position-instance_method) | `'position'` where the model keeps an integer one | the column a reader drags the rows into order by, or `nil` for a table nobody positions |
| [`recourse_icon`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_icon-instance_method) | the model's name | the icon on the sidebar, the crumbs and the tabs |
| [`recourse_includes`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_includes-instance_method) | every `belongs_to` | what the index eager-loads, in any shape `includes` takes |
| [`recourse_broadcasts?`](https://rubydoc.info/gems/recourse/Recourse/Broadcasting#recourse_broadcasts%3F-instance_method) | `true` | whether saving a record redraws every open index listing it |

For instance, this would yield a more compact `index` than the default configuration:

```ruby
class Post < ActiveRecord::Base
  def self.recourse_label = :title                    # Label a post with its title
  def self.recourse_hidden = %i[ip_address]           # Hide the IP address from the views
  def self.recourse_order = { published_at: :desc }   # Sort posts by last published first
  def self.recourse_icon = :question                  # Represent Posts with a question icon
end
```

[image]

What the schema already says needs nothing declared. A number is drawn as a count,
headed with what it counts and linking to the rows behind it, when its column holds a
counter cache or is named `<association>_count` for an association the model has. An
enum is a badge on a page, a menu on a form and a filter beside the search box, and so
is a boolean and every foreign key whose table is short enough to list. An encrypted
column stays off every table, arrives masked on the record's page and is offered in the
clear on its form. A `has_one_attached` is a file field and a picture; a
`has_many_attached :photos` is a page of its own once `recourses :photos` is routed
under the record.

Filters are drawn per enum, per boolean and per foreign key. A model adds one the schema
says nothing about — a word reached through another table — by naming the predicate,
and the gem reads the words off the model behind it:

```ruby
def self.filter_fields = super + %i[team_name_in]
```

Naming a filter is not leave to query through a table, so `ransackable_associations`
still says how far Ransack may reach — and a filter Ransack will not answer is refused
while the page draws rather than left to narrow nothing.

## Step 3. Delete your views

If you are happy with the generated HTML files, then be happy to skip this step!
If you want even more configuration, then just add a `app/views/<resources>/_row.html.erb` partial.
You can use [`column`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Cells#column-instance_method),
[`sort_header`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Sorts#sort_header-instance_method)
and [`search_highlight`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Searches#search_highlight-instance_method)
to define the columns you want:

```erb
<%# app/views/admin/providers/_row.html.erb %>
<%# locals: (provider:) -%>

<%= column header: sort_header(:name) do %>
  <%= search_highlight provider.name, :name %>
<% end %>

<%= column header: 'Phone' do %>
  <%= number_to_phone provider.phone %>
<% end %>
```

[image]

A `_fields.html.erb` replaces the fields of a form the same way, and a `show`, `edit` or
nested `index` template of your own replaces the body of that page and nothing else:
the card, its tabs, the buttons beside the breadcrumb and the tab's title are the
layout's, so a page you write is its content alone. A page that wants the width to
itself assigns `@recourse_card = false`.

## Step 4. Secure your controllers

Every controller the gem defines inherits
[`RecoursesController`](https://rubydoc.info/gems/recourse/Recourse/BaseController),
which the host defines to put behavior above every screen at once:

```ruby
class RecoursesController < Recourse::BaseController
  before_action :authenticate!
end
```

A controller the app already defines is left alone, and one line of it is usually
enough: `recourse_relation` puts a scope of your own behind a table the gem draws
whole, and `find_resource` finds a singular record the parent names no association for.

## Step 5. Enjoy the extras

The rest of what the gem offers. The first two are a line each in
`config/initializers/recourse.rb`; the others need nothing beyond what the model
already declares, or one keyword in the routes.

### Color and theme

[`Recourse.color=`](https://rubydoc.info/gems/recourse/Recourse#color%3D-class_method)
says which Bootstrap family is primary on every page, and
[`Recourse.theme=`](https://rubydoc.info/gems/recourse/Recourse#theme%3D-class_method)
says which color scheme the pages are drawn in — one of `Recourse::THEMES.keys`: eight
palettes taken from code editors, plus Bootstrap's own.

```ruby
Recourse.color = :orange
Recourse.theme = :nord
```

The theme is where a reader starts, not where they stay. The moon at the foot of the
sidebar rotates through every palette, light and dark, and the one they pick stays in
their browser. Times are drawn in the reader's own zone the same way, reported by their
browser and never written to the host.

### Bookmarks

[`Recourse.bookmarks=`](https://rubydoc.info/gems/recourse/Recourse#bookmarks%3D-class_method)
takes a Proc answering the rows the viewer has kept:

```ruby
Recourse.bookmarks = -> { Keepsake.where agent: Current.agent }
```

A Proc rather than a relation, because at boot the viewer is nobody. Every model with a
`has_many` at that class then opens its table with a square to keep a row by, and kept
rows come first. A model that cannot hold a bookmark gets no column, and neither does a
visitor the Proc answers nil for — somebody who never signed in has nowhere to keep one.

<img width="3824" height="1220" alt="Image" src="https://github.com/user-attachments/assets/d1db4adb-0b5c-4e41-8bb6-cf72a35288f0" />

### Maps and calendars

A table whose model keeps a `google_place_id`, or a `latitude` and a `longitude`, can be
read as a Google map of the same page: the footer under it offers `Display as map`, and
`/counties.map` draws this page's rows in the frame and over the footer the table has, so
search, sort and pages work the same on either shape. The key and the map ID are the
host's own credentials, under `google_maps` as `api_key` and `map_id`.

A table whose model keeps a `starts_at` and an `ends_at` can be read as a week of the
same rows: the footer offers `Display as calendar`, and `/shifts.cal` draws a column a
day with each row placed by the hours it runs between. `?week=2026-09-13` moves to the
week holding that day, and the search and the filters travel with it.

### Positionable tables

A table whose model keeps an integer `position` is one a reader puts in order by hand: a
grip opens each row, dragging it moves the row, and the place it lands in is written to
the route `positionable: true` drew under the index. The column decides the rest — the
grips, the callbacks that keep the numbers running 1, 2, 3, and `recourse_order`, since
the order a table is read in and the order somebody put it in are one fact. A model
pointing two ways says which of them its place is counted within:

```ruby
class Step < ActiveRecord::Base
  belongs_to :team
  belongs_to :person

  def recourse_siblings = team.steps
end
```

### Retrievable tables

A table whose rows come from somewhere else — a CRM, a feed — offers to fetch them
again: `recourses :visits, only: :index, retrievable: true` draws
`POST /providers/5/visits/retrieval` and the `Retrieve` button that posts to it. Where
the rows come from is the host's to know, so `Providers::Visits::RetrievalsController`
is the host's to write, and `recourse_retrievable?` on the listing controller is how a
page says there is nothing to fetch from.

## Development

```bash
bin/setup            # installs the bundle
bundle exec rake     # the suite at 100% coverage, RuboCop, and the file-length ceiling
cd test/dummy && bin/rails server
```

The dummy app under `test/dummy` runs on SQLite; the gem names no adapter.

### Reading an unpublished bundle

The pages link bh's own files, so a stylesheet or a Stimulus controller that is not
published yet is read by pointing the Gemfile at a checkout of it beside this one:

```bash
echo "gem 'bh', path: '../bh'" >> Gemfile && bundle install
cd test/dummy && bin/rails db:migrate && bin/rails server
```

A host serving those three folders from somewhere else — a CDN, a bundle of its own
carrying bh's layer — says so in `Recourse.assets`, and that is the whole of what it
writes. The dummy's development database is migrated on its own, which the line above is
why.

## License

[MIT](MIT-LICENSE).
