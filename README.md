# Recourse

Swap two characters in your `config/routes.rb` and get awesome admin screens for your Rails app.

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

[image]

Every recourse with `show` gets a detail page where attributes are displayed with the appropriate
formatting, or masked if sensitive:

[image]

Every recourse with `new` or `edit` gets a form with appropriate browser formatting and validation:

[image]

Every recourse with `destroy` gets a button with a detailed confirmation message:

[image]

Every nested recourse gets namespaced after the parent:

[image]


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

Here are some bonus features the gem provides. Customize them by editing their values in
your `config/initializers/recourse.rb` file:

- [`Recourse.color=`](https://rubydoc.info/gems/recourse/Recourse#color%3D-class_method):
  which Bootstrap family is primary on every page. Readers switch light and dark themselves.
- [`Recourse.bookmarks=`](https://rubydoc.info/gems/recourse/Recourse#bookmarks%3D-class_method):
  a Proc answering the viewer's bookmark rows. Every table of a model with a `has_many`
  at that class then opens with a square to keep a row by, kept rows first.

```ruby
Recourse.color = :orange
Recourse.bookmarks = -> { Keepsake.where agent: Current.agent }
```

## Development

```bash
bin/setup            # installs the bundle
bundle exec rake     # the suite at 100% coverage, RuboCop, and the file-length ceiling
cd test/dummy && bin/rails server
```

The dummy app under `test/dummy` runs on SQLite; the gem names no adapter.

## License

[MIT](MIT-LICENSE).
