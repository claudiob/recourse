# Recourse

Swap two characters in your `config/routes.rb` and get awesome admin screens for your Rails app.

## How to install

```bash
gem install recourse
```

```ruby
# Gemfile
gem 'recourse', '~> 5.0'
```

`~> 5.0` follows Semantic Versioning: `bundle update` takes every 5.x and never a
breaking change. Rails 8.1 and Ruby 3.2 are the minimum; the pages need Turbo, which
`turbo-rails` brings, and nothing else in the host. Everything a page is styled and
scripted by — Bootstrap 6, its icons, Turbo, Stimulus and the controllers behind these
screens — is linked from https://design.houseaccount.com, so a host without an asset
pipeline gets the same screens, and a host with a Content Security Policy allows that
origin for `style-src`, `script-src` and `font-src`.

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
formatting, or masked if sensitive:

<img width="3824" height="2274" alt="Image" src="https://github.com/user-attachments/assets/515f63c4-8a9b-422e-95c4-88d6647911d8" />

Every recourse with `new` or `edit` gets a form with appropriate browser formatting and validation:

<img width="3824" height="1220" alt="Image" src="https://github.com/user-attachments/assets/ebe5108b-bbd1-4cd1-a635-89eef0e6fc50" />

Every recourse with `destroy` gets a button with a detailed confirmation message — on its
edit page, or on each row of its table where no `edit` is routed:

[image]

Every nested recourse gets namespaced after the parent:

<img width="3824" height="2274" alt="Image" src="https://github.com/user-attachments/assets/9b242335-a25b-4fa8-8023-422538d235b0" />


## Step 2. Enhance your models

To change the content displayed in the `index` table of a model, override any of these class methods:

| Hook | Default | Decides |
| --- | --- | --- |
| [`recourse_label`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_label-instance_method) | `:name` | the column a combobox shows and a foreign-key cell reads; typed rather than picked where it has a length validator |
| [`recourse_hidden`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_hidden-instance_method) | `[]` | columns kept off the table, the page, the form and the search |
| [`recourse_displayed`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_displayed-instance_method) | `[]` | columns a table draws that it would leave off: encrypted ones, the id, timestamps, JSON |
| [`recourse_order`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_order-instance_method) | `:id` | the index's order, a Symbol or a Hash; rows with nothing in the column come last |
| [`recourse_icon`](https://rubydoc.info/gems/recourse/Recourse/Recoursive#recourse_icon-instance_method) | the model's name | the icon on the sidebar, the crumbs and the tabs |

For instance, this would yield a more compact `index` than the default configuration:

```ruby
class Post < ActiveRecord::Base
  def self.recourse_label = :title                    # Label a post with its title
  def self.recourse_hidden = %i[ip_address]           # Hide the IP address from the views
  def self.recourse_displayed = :created_at           # Display the created_at in the views
  def self.recourse_order = { published_at: :desc }   # Sort posts by last published first
  def self.recourse_icon = :question                  # Represent Posts with a question icon
end
````

[image]

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

## Step 4. Secure your controllers

Every controller the gem defines inherits
[`RecoursesController`](https://rubydoc.info/gems/recourse/Recourse/BaseController),
which the host defines to put behavior above every screen at once:

```ruby
class RecoursesController < Recourse::BaseController
  before_action :authenticate!
end
```

A controller the app already defines is left alone.


## Step 5. Enjoy the extras

The rest of what the gem offers, in four parts. The first two are a line each in
`config/initializers/recourse.rb`; the last two need nothing beyond what the model
already declares.

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
their browser.

### Bookmarks

[`Recourse.bookmarks=`](https://rubydoc.info/gems/recourse/Recourse#bookmarks%3D-class_method)
takes a Proc answering the rows the viewer has kept:

```ruby
Recourse.bookmarks = -> { Keepsake.where agent: Current.agent }
```

A Proc rather than a relation, because at boot the viewer is nobody. Every model with a
`has_many` at that class then opens its table with a square to keep a row by, and kept
rows come first. A model that cannot hold a bookmark gets no column.

<img width="3824" height="1220" alt="Image" src="https://github.com/user-attachments/assets/d1db4adb-0b5c-4e41-8bb6-cf72a35288f0" />

### Attachments

What a model keeps as files needs nothing declared either. A `has_one_attached :logo` is
a file field on the form and, on the record's page, the picture Active Storage makes of
the file — 100 pixels tall, WebP where the browser takes it, opening the whole file in a
new tab — or the file's name where nothing can be drawn of it.

A `has_many_attached :photos` earns a page of its own, nested under the record:

```ruby
recourses :photos, only: %i[index destroy]
```

That page is a table of the files with their pictures, and a Delete on each row that
takes the file off the record. Files are added on the record's own form, where a chosen
file joins a shelf and replaces a single one, and a field nobody touched leaves
everything as it was. `recourse_hidden :photos` keeps a file off every screen the way it
keeps a column off.

Drawing a picture of an image needs `image_processing`; video and PDF also need the
host's `ffmpeg` and `poppler`.

### Maps

A table whose model keeps a `google_place_id`, or a `latitude` and a `longitude`, can be
read as a Google map of the same page: the footer under it offers `Display as map`, and
`/counties.map` draws this page's rows in the frame and over the footer the table has, so
search, sort and pages work the same on either shape.

A point is a pin. A place ID is filled in as an area where the model is a geography
Google draws boundaries for — a `State`, a `County`, a `City` or a `ZIP`, by name — and
pinned at the place for any other model.

The key and the map ID are the host's own credentials:

```yaml
# config/credentials.yml.enc
google_maps:
  api_key: AIza…
  map_id: 4f2a…
```

The map's style has the matching **Feature layers** turned on in the Cloud console —
Postal code for ZIPs, Administrative area level 2 for counties. A host with a Content
Security Policy allows `maps.googleapis.com` for scripts and connections, and Google's
tile hosts for images.


### Calendars

A table whose model keeps a `starts_at` and an `ends_at` can be read as a week of the same
rows: the footer offers `Display as calendar`, and `/shifts.cal` draws a column a day with
each row placed by the hours it runs between — rows that overlap in lanes of their own,
and each led to its own page where the routes drew one.

```ruby
recourses :shifts
```

A week rather than a page is what a calendar shows, so there is nothing to paginate:
`?week=2026-09-13` moves to the week holding that day, and `Previous week`, `This week`
and `Next week` stand where the pages stand under a table. The search and the filters
travel with it, so a calendar narrowed to one person stays narrowed as the weeks move.

The week opens on Sunday and the hours are the reader's own — the same cookie every other
time on these pages is drawn against — and the scale runs only over the hours that week's
rows cover, or a working day where it holds none. A row running past midnight is drawn on
the day it opens, down to the foot of its column.

Both columns have to be datetimes, asked through `type_for_attribute`, so an
`attribute :starts_at, :datetime` override counts and a column of another kind named
`starts_at` earns nothing.


## Development

```bash
bin/setup            # installs the bundle
bundle exec rake     # the suite at 100% coverage, RuboCop, and the file-length ceiling
cd test/dummy && bin/rails server
```

The dummy app under `test/dummy` runs on SQLite; the gem names no adapter.

## License

[MIT](MIT-LICENSE).
