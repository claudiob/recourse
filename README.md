# Recourse

Admin screens for a Rails app, drawn from its models. One word in `config/routes.rb`
serves a resource's seven actions — a paginated, searchable, sortable, filterable index
table, a record's page, its form and its delete — with no controller, view or partial
added to the app. What each screen shows is read off the model: its columns, its
validators, its associations and its indexes.

Everything a host may call is listed below with a link to its reference on
[RubyDoc](https://rubydoc.info/gems/recourse). Every default can be overridden by
defining the same thing in the app.

## How to install

```bash
gem install recourse
```

```ruby
# Gemfile
gem 'recourse', '~> 4.0'
```

`~> 4.0` follows Semantic Versioning: `bundle update` takes every 4.x and never a
breaking change. Rails 8.1 and Ruby 3.2 are the minimum; the pages need Turbo, which
`turbo-rails` brings, and nothing else — Bootstrap and its icons are vendored and served
by the engine, so a host without an asset pipeline gets the same screens.

## In `config/routes.rb`

[`recourses`](https://rubydoc.info/gems/recourse/Recourse/Routes#recourses-instance_method)
is `resources` with a controller and views supplied. It takes the same `only:` and
`except:`, and a block nests children under the parent:

```ruby
scope module: :admin do
  recourses :providers do
    recourses :markets, only: :index               # a counted tab on each provider
    recourses :retrievals, only: :create           # a button on each provider
  end
  recourses :searches, only: %i[index show new create]
end
```

- Every resource with an `index` gets a sidebar entry, in routes order, with a keyboard
  shortcut on its first letter. `only: []` declares a resource with no page of its own.
- A nested `index` is a tab on the parent's card, counted where a `counter_cache` exists.
- A nested `create` with no index is a button on the parent's page, named after the
  route. The host answers it in a controller of its own, or the gem creates the record.
- Nested controllers are namespaced after the parent (`Admin::Providers::MarketsController`),
  and a nested index lists only the parent's rows.
- Do you name a route `exit`? The sidebar ends with a log-out button submitting a
  `DELETE` to it:

  ```ruby
  resource :session, only: :destroy, as: :exit
  ```

## In `app/controllers/recourses_controller.rb`

Every controller the gem defines inherits
[`RecoursesController`](https://rubydoc.info/gems/recourse/Recourse/BaseController),
which the host defines to put behavior above every screen at once:

```ruby
class RecoursesController < Recourse::BaseController
  before_action :authenticate!
end
```

A controller the app already defines is left alone.

## In `config/initializers/recourse.rb`

- [`Recourse.color=`](https://rubydoc.info/gems/recourse/Recourse#color%3D-class_method):
  which Bootstrap family is primary on every page. Readers switch light and dark themselves.
- [`Recourse.bookmarks=`](https://rubydoc.info/gems/recourse/Recourse#bookmarks%3D-class_method):
  a Proc answering the viewer's bookmark rows. Every table of a model with a `has_many`
  at that class then opens with a square to keep a row by, kept rows first.

```ruby
Recourse.color = :orange
Recourse.bookmarks = -> { Keepsake.where agent: Current.agent }
```

## In a model

Every Active Record model answers these; a model overrides one in a
[`Recoursive`](https://rubydoc.info/gems/recourse/Recourse/Recoursive) concern of its own.

```ruby
# app/models/market/recoursive.rb
module Market::Recoursive extend ActiveSupport::Concern
  class_methods do
    def recourse_label = :slug                     # what a menu and a cell call one
    def recourse_hidden = %i[callback_url payload] # off every screen
    def recourse_displayed = :created_at           # back on the table
    def recourse_order = { size: :desc }           # how the index sorts
    def recourse_icon = :question                  # a Unicon concept
  end
end
```

| Hook | Default | Decides |
| --- | --- | --- |
| [`recourse_label`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_label-instance_method) | `:name` | the column a combobox shows and a foreign-key cell reads; typed rather than picked where it has a length validator |
| [`recourse_hidden`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_hidden-instance_method) | `[]` | columns kept off the table, the page, the form and the search |
| [`recourse_displayed`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_displayed-instance_method) | `[]` | columns a table draws that it would leave off: encrypted ones, the id, timestamps, JSON |
| [`recourse_order`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_order-instance_method) | `:id` | the index's order, a Symbol or a Hash; rows with nothing in the column come last |
| [`recourse_icon`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_icon-instance_method) | the model's name | the icon on the sidebar, the crumbs and the tabs |

What needs no hook, being read off the model:

- The index eager-loads every `belongs_to` the table names, sorts by whatever an index
  covers, searches through its indexed string columns and the labels behind its foreign
  keys, marks what it matched, and offers a filter menu per enum, boolean and `belongs_to`.
- Saving a row refreshes every open index of it.
- A form field per column, carrying the rules the validators state: a length is a
  `maxlength`, a format a `pattern`, a numericality a numeric keyboard.
- An enum is a badge on a page and a menu on a form; a foreign key is a menu of the
  records it points at, or a field to type the label into where there are too many.
- Values formatted by kind: delimited integers, money, phone numbers, dates and times in
  the reader's own time zone, a `<time>` saying how long ago, a URL as a link, a list as
  a count that opens.
- An encrypted column stays off the table, arrives masked on the record's page behind a
  `Show`, and is edited in the clear.
- The delete button names what goes with the record, counted one association down.

## In `app/views`

Do you want your own cells? Add `app/views/<resources>/_row.html.erb` and build it from
[`column`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Cells#column-instance_method),
[`sort_header`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Sorts#sort_header-instance_method)
and [`search_highlight`](https://rubydoc.info/gems/recourse/Recourse/Helpers/Searches#search_highlight-instance_method):

```erb
<%# app/views/admin/providers/_row.html.erb %>
<%# locals: (provider:) -%>
<%= column header: sort_header(:name) do %>
  <%= search_highlight provider.name, :name %>
<% end %>
<%= column header: 'Phone' do %><%= number_to_phone provider.phone %><% end %>
```

Any template or partial of the gem's is replaced by defining it in the app, under the
resource (`app/views/admin/providers/index.html.erb`) or for every resource at once
(`app/views/recourses/_sidebar.html.erb`). Every string the gem shows is a key under
`recourse` in `config/locales/recourse.en.yml`, so a host rewords `Add provider` in a
locale file of its own.

## Development

```bash
bin/setup            # installs the bundle
bundle exec rake     # the suite at 100% coverage, RuboCop, and the file-length ceiling
cd test/dummy && bin/rails server
```

The dummy app under `test/dummy` runs on SQLite; the gem names no adapter.

## License

[MIT](MIT-LICENSE).
