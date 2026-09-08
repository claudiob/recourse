# Recourse

A `routes.rb` DSL that mounts ready-made resource screens.

Add one line to `config/routes.rb` and Recourse draws the routes and serves the
controller and views needed to browse and edit a resource. Nothing is written
into your app: every controller, template and partial it supplies is a default,
and defining your own takes precedence over it.

> **Status:** version 4 is a rewrite of the gem published as `recourse` 1 to 3,
> and continues its version line.

## Requirements

- Ruby 3.2 or newer.
- Rails 8.1 or newer — `actionpack`, `activerecord` and `railties`.
- `pagy` 43.6 or newer, which paginates every index.
- `ransack` 4.4 or newer, which sorts, searches and filters every index.
- `turbo-rails`, which every frame, every morph and every warning before a delete
  is drawn through.
- `unicon` 3.0 or newer, which names every icon drawn — a model's own, and the
  gem's — in each design system. 3.0 is where its actions became verbs.

## How to install

To install on your system, run

    gem install recourse

To use inside a bundled Ruby project, add this line to the Gemfile:

    gem 'recourse', '~> 4.0'

Since the gem follows [Semantic Versioning](http://semver.org), indicating `~> *major*.*minor*`
guarantees your project won’t occur in breaking changes whenever you `bundle update`.

Then run `bundle install`. There is nothing to mount and no initializer to
write: the engine adds the routing DSL, the model hooks and a file server for
its own CSS and JavaScript as the app boots.

## `recourses`

```ruby
# config/routes.rb
Rails.application.routes.draw do
  recourses :contacts
  recourses :markets, only: %i[index new create edit update]
  recourses :states, only: :index
  recourses :placeholders, only: []
end
```

`recourses` accepts everything `resources` accepts — `only:`, `except:`, a
block to nest in — and for each name it does three things:

1. Records the name in `Recourse.declared`, in the order `routes.rb` lists it.
   The sidebar follows that order, not an alphabetical one.
2. Defines `ContactsController` as a subclass of `RecoursesController`, unless
   the constant already resolves. A Zeitwerk autoload counts, so a file in
   `app/controllers` is enough to keep the gem from defining anything.
3. Draws the routes, by calling `resources` with the arguments it was given.

Because the third step is plain `resources`, `recourses :contacts` routes all
seven actions, and all seven are answered.

A *nested* `recourses` is the one exception: it defaults to
`only: %i[index new create]` — the collection actions, which are what makes
sense reached through a parent, while the member pages belong to the resource's
own top-level routes. The nested pages take the hint: the index lists only the
parent's rows and drops its column, the search form drops the parent's own
filter and the search box stops reaching through the parent's label — a model
searched only that way loses the form altogether — and the form drops its
field — a comment
under `/posts/2` is for post 2, not for one picked from a menu, so no field
asks and `create` writes the route's parent whatever a form is made to submit.
Routed `create` without `new`, a nested resource offers a one-click `Create`
button in the Add link's place: it posts the record whole and returns to the
index holding it. Declaring the routes that way is your word that a bare record
can stand — validations are yours to reconcile.
The nested index also sits in the parent record's own card, beside its Show and
Edit tabs — as a tab named by the count where the parent keeps a counter cache,
`42 comments`, and by the bare `Comments` where it does not — and the
breadcrumb's record crumb links back to the parent's show page where one is
routed.
A `namespace` may sit between a `recourses` block and what it nests, and
everything follows it: the routes and controllers come out where you would
expect — `/posts/1/featured/comments` served by
`Posts::Featured::CommentsController` — and so do the crumbs, the card and the
count. The namespace leads the tab it earns, so two nestings of one model read
apart: `12 featured comments` beside `4 flagged comments`, and
`Featured comments` beside `Flagged comments` where no counter cache answers.
The icon is the counted model's own either way.
What the nesting does not take away is a row: the eye and the pencil are the
ones the top-level table draws, pointing at `/comments/2` and
`/comments/2/edit` — the member pages the nesting left to the resource itself —
and a counter cell links to the resource's own nested index the same way. A
nested table is the top-level one, minus the parent's column.
The parent is found by the key pointing at it, which for a polymorphic
`belongs_to` names no one table — `/posts/2/comments` says `post`, never
`about`. What settles it there is the parent's own half: write
`has_many :comments, as: :about` on the post and the nesting is that
association, whichever of the model's keys it is. The page then reads like any
other nested one, and the write puts the class name beside the id. A parent
declaring no such `has_many` resolves no parent at all — a page gathered from
several parents at once is nobody's one record, and `recourse_relation` is
still what scopes it.
An explicit `only:` or `except:` is your word and wins:

```ruby
recourses :posts do
  recourses :comments                    # index, new and create — the default
  recourses :ratings, only: %i[index show] # exactly what it says
end
```

A resource with no `index` route gets no sidebar entry, which is what
`only: []` is for.

`recourse` draws what Rails' `resource` draws, and the gem records it the same way:
one record reached with no id of its own, at `/locations/5/property`. Rails routes a
singular resource to a plural controller, so `Locations::PropertiesController` is what
answers, and a `has_one` needs no id in the path. What such a nesting earns on the
location's card depends on what it routes, and only on that. Routed `show`, it earns a
tab reading the model's own word in the singular — `Property`, or `HouseCanary` where a
locale renamed the model — pointing at that one page. Routed `create` or `destroy` and
neither `index` nor `new`, it earns a button beside the breadcrumb instead: `Add
property`, `Delete property`. Routed both, it earns both, which is a page to read and a
verb to press — and the button then stands on that page rather than on every page the
record has, since a page of its own is somewhere for it to be. Which verb it offers is
the record's to say: `Add property` while the `has_one` holds nothing, `Delete property`
once it does, and never both. An action with no page anywhere — `recourse :sweep, only:
:create` — has nowhere of its own, so its button stands on the record's own show page,
every other page of the record being about something else.

A singular resource has no id to look up, so the gem reads the record off the parent
under the name the route already gives it — `location.property`, whether the parent
keeps it with a `has_one` or points at it with a `belongs_to`. Where the association
holds nothing, a resource routed `new` sends you to the form that makes one, and a
resource without one says `No property.` on the page. And a write has no index to
return to, so it lands on the record's own page instead: a singular resource is the
collection of one.

Where the parent has no association of that name, the record is still yours to find —
`def find_resource = assign @recourse_parent.chat` in a controller of your own — which
is what a page reached through something else needs, a chat a nomination gets through
its booking. The gem assigns nothing in that case, so an override is all there is to
write, and anything else the page needs goes beside it.

A resource names a model, and a name that resolves to none is an error rather
than a mystery: `recourses :pizzas` with no `Pizza` in the app answers

> You declared `recourses :pizzas` in your routes file, but this app has no Pizza
> model.

which is a `Recourse::Error`, so a host can rescue it like anything else the gem
raises. Write the controller yourself if a resource of yours is not backed by a
model at all — the gem defines one only where you have not.

`recourses` works inside a `namespace` too, and the controller it defines follows
the namespace rather than the resource:

```ruby
namespace :admin do
  recourses :sources, only: :index
end
```

draws `/admin/sources` and defines `Admin::SourcesController`, making the `Admin`
module itself if your app has none — a namespace is a routing decision, and Rails
draws it whether or not a module exists to match. The sidebar entry links to
where the routes were drawn, and a namespaced resource and its top-level twin are
separate entries: `/sources` and `/admin/sources` never mark each other as the
page being shown.

## The screens

| Action | What it answers |
| --- | --- |
| `index` | one page of the model — 20 rows or 100, as the reader chose, `?page=2` for the next |
| `show` | the record the id names, read out |
| `new` | a blank record's form, or one filled in from `?cloned_id=` |
| `create` | the index again, or the form with the errors on it |
| `edit` | the form for the record the id names |
| `update` | the index again, or the form with the errors on it |
| `destroy` | the index again, without the record |

`index` reads the model's `recourse_includes` and `recourse_order`, so a table
cell naming a referenced record costs no query of its own. Its columns read in the
order their kinds earn rather than the order the schema happens to keep them in: the
counts, then what kind of row it is and what state it is in, its flags, whose it is,
what it says, the long values, when it happened, and last the two timestamps. Inside
one of those a column keeps the place the table gave it, so an order already in the
schema stands — and a column added later joins its own kind rather than the end of the
row, which is the one thing no migration can arrange. The table hides
every encrypted column — and `type`, the column Rails reserves for single table
inheritance, stays off every screen: a class name is machinery, not an
attribute. A model with no rows renders `No contacts.` instead. A heading sorts the table by its own column where the model allows
it, and the form above the table narrows what it shows, by search or by
filter.

### A table somebody arranged

A model may say that a column holds an order somebody put its rows in rather than
one the database found, by writing `:positionable` where a direction would go:

```ruby
def recourse_order = { position: :positionable }
```

The index then draws a grip beside each row and no heading to sort by — a second
way to read the rows would contradict the order they were put in — and a drop
writes the row's new place. Only where the arranging means something: a table
nothing points away from is one arrangement, and a nested index is another, but
the resource's own index of every parent's rows at once is neither, and sorts and
searches like any other.

Two things go with that, and both come with the word: nothing to include and
nothing to remember. A new row lands last among its own, since the form the gem
draws never asks for a position. The gap closes behind one that goes, since what a
drop reports is a row's place on the page — a position only while the table runs
1, 2, 3 with no gaps in it. The rows either is counted among are worked out from
the model: what it points at, or the whole table where it points nowhere. Where
more than one key could be the parent, the model says which:

```ruby
# A picture belongs to a department and to the file it shows, and its place is
# among the department's.
def recourse_siblings = Picture.where(department_id:)
```

A model names one such column, and `recourse_order` refuses a second: the order a
table is read in and the order somebody put it in are one fact. A *listing* may be
in another order, though — a plan holds a place among its service's plans and
another among every plan of its department, which is reached through the service
and by no key of the plan's own. Which of them a page is in is the page's answer:

```ruby
class Admin::Departments::PlansController < RecoursesController
private

  def find_parent = @recourse_parent = Department.find(params.expect(:department_id))
  def recourse_relation = @recourse_parent.plans.order(:ordering)
  def recourse_position = 'ordering'
end
```

Three things come with taking it over, since the gem only maintains the column
`recourse_order` nominates. The positions controller the gem drew under that index
has to be told the same two things — define it and it wins, as any controller of
yours does — or a drop renumbers rows the page never showed:

```ruby
class Admin::Departments::Plans::PositionsController < Recourse::PositionsController
  include Admin::Departments::Plans::Arranged  # the two methods above, written once
end
```

Filling the column on create and closing its gap on delete is yours, the way
`recourse_siblings` is the gem's for the model's own. And whatever did the shifting
before has to stop: `Positioning` moves the block now, and two things shifting the
same neighbours leave two rows holding one number.

Moving a row is the gem's. Writing a new position on the record itself is not, so
a host whose own pages do that keeps whatever closes up behind it — two things
shifting the same neighbours leave two rows holding one number.

A show page reads what the form offers and whatever `recourse_displayed` names
besides, which is how a column is read where it is not typed: a band's label is
written by the model and is the first thing to know about one, and hiding it to
keep it off the form would otherwise keep it off the record's own page too.

`show` reads one record out where its form would have been: the same grid the
edit page uses, `lg:col-6` so it is two columns on a large viewport, with the
heading a form would give each column above and what the record says below, and a
rule under each row of two. Both pages lay a row out with the same class, and the
edit page reserves the width of that rule without drawing one, so a field sits at
exactly the height of the value it edits and switching tabs moves nothing but the
controls. No
form and no field — a value the record has nothing for reads as an em dash. It
lists the same columns the form offers, so the two pages never disagree about
which attributes a record has.

Each value reads as what it is of rather than as what it is stored as: a boolean is
the word it is, `true` or `false` — a column the record never answered reads as the
dash any unanswered column does, and `false` never does, since what earns a dash is
formatting to nothing rather than being falsy —
an enum is a badge, an integer carries its delimiters, a decimal is rounded to its
own scale, a `:monetary` wears the currency and a `:percentage` a `%`, a `:month`
reads as the word for one and a `:year` as its digits, and a phone is
punctuated. One whole web address is a link to itself, and reads as its host: no
protocol, no leading `www.`, and `/…` where a path follows — the href carries the rest,
which is what a click needs and a column has no room for. A counter cache is not shown at all, being Rails' to keep rather than
anyone's to read. The kinds and the helpers behind them are the table under
["What a field becomes"](#what-a-field-becomes), which the form reads too — one
question, two answers.

Encrypted columns are among them, and they arrive masked: one `*` per character,
with a `Show` beside it that swaps the plaintext in. The value travels in a
`data-reveal-plain-value` attribute and a Stimulus controller does the swap, so a
screenshot of the page catches asterisks and reading one value is a deliberate
click. Encryption settles what the database keeps; the mask settles what a screen
gives away.

`show` and `edit` are what an index row links to, an eye then a pencil, and each
appears only where its action is both implemented and routed. A resource with
neither gets no `Actions` column at all. Those two are named as Unicon concepts
like every other icon here — `:view` and `:edit` — so what draws them is the
icon set's business rather than a Bootstrap class written into the gem.

Both pages wrap their content in a Bootstrap card whose header is a row of tabs,
one per page the record has — `Show` behind the eye, then `Edit` behind the
pencil, then one per resource nested under the record that routes a page of its own:
an index, or the single record a `recourse` draws. The page being read is marked
`active` and `aria-current='page'`. They are links rather than a JavaScript tab set,
since each is a page of its own; a resource with only one of the two gets a card with
one tab.

`new`, `show` and `edit` assign the record twice: to `@recourse`, and to the name
Rails would use, so `@contact` is what a view of yours can read.

`destroy` is offered from the edit page, as a button beside the breadcrumb, and
only where the action is both implemented and routed. It asks first, through
`data-turbo-confirm`, naming the record and counting one level of what goes with
it: `2 messages will be deleted with it.` for a `dependent: :destroy`,
`1 message will be kept, without a job.` for a `:nullify`, and
`Anything under those goes too.` in place of the levels below — a state reaches
counties, then ZIPs, then locations, and counting that far would join 40,965 rows
to draw one page. Without Turbo loaded there is no confirmation at all, only the
delete.

`create` and `update` permit every editable column, then take one of two
branches. Saved, they set `flash.notice` to `Contact was created.` and redirect
to the index with `303 See Other`; rejected, they set `flash.now.alert` and
re-render the form with `422 Unprocessable Entity`. `show`, `edit`, `update` and
`destroy` look their record up with `find`, so an id that names nothing raises
`ActiveRecord::RecordNotFound` and Rails answers `404`.

Two column lists decide what a screen shows, and they are deliberately not the
same one:

- A table shows every column except the encrypted ones, so a column holding PII
  never reaches an index page, and except the primary key. `attr_readonly` means
  nothing here: a column written once is still a column, and a model that would
  rather no screen drew it says `recourse_hidden`. A model that wants one of those
  defaults overruled says `recourse_displayed`, which is the other hook a host
  decides: `def recourse_displayed = :phone` puts a number back on a table that
  recognises its rows by nothing else. `created_at` and `updated_at` are hidden the
  same way, and shown by the same hook —
  `def recourse_displayed = %i[created_at updated_at]` — coming last when it does,
  after whatever the record is actually about, in that order however they were named.
  A `json` or `jsonb` column is hidden the same way and for the same reason: a payload
  is a service's answer kept whole, one value as wide as the page, and a column of them
  is a table nobody can read. The record's own page still reads it out.
- A form offers, and `create` permits, `Recourse.editable_columns` — every
  column except `id`, `created_at`, `updated_at` and any counter cache. Encrypted
  columns are offered too, carrying the record's own value in the field its kind
  earns — so saving a change to one column does not demand every encrypted one be
  retyped, and so a value can be read before it is changed.

The show page reads from the second of those two, the form's list, which is why an
encrypted column reaches it — masked — while no index table draws one at all. A
table is a page of records and a screenful of PII; a show page is one record, read
on purpose.

A column holding a counter cache is headed with what it counts — `ZIPs` rather
than `ZIPs count` — which the gem reads from the `counter_cache` on the other side
of the association rather than from the column's name. Every cell in it leads with
the icon of what is counted, so `<i class='bi bi-geo-alt'></i> 26`.

A cell renders by what the column holds: a `belongs_to`'s foreign key as the
label of the record it points at, a time as `Aug 4 at 03:47pm EDT`, a `phone`
through `number_to_phone`.

## What a model can say

Every Active Record model answers a handful of class methods: the engine
extends `ActiveRecord::Base` with `Recourse::Recoursive` on load, so the
defaults are there without a model mentioning them.

| Method | Default | What it decides |
| --- | --- | --- |
| `recourse_icon` | the model's own name, as a concept `Unicon` resolves | the icon a link to this resource is drawn with |
| `recourse_label` | `:name` | the column that stands for a record — what a combobox lists, and what a table cell shows for a foreign key pointing here |
| `recourse_typed_label?` | true when that column has a length validator | whether a foreign key to this model is typed into a text field or picked from a list |
| `recourse_includes` | every `belongs_to` the table names | what the index eager-loads, in any shape `includes` accepts |
| `recourse_order` | `:id` | how the index sorts, in any shape `order` accepts — one key may read `:positionable` instead of a direction, which arranges the table by hand |
| `recourse_cloned` | `[]` | the associations a copy of a record carries with it — see [Cloning a record](#cloning-a-record). Nothing is carried that is not named |
| `recourse_displayed` | `[]` | columns a table and a show page draw that they would otherwise leave off — the encrypted ones, the primary key, a polymorphic `*_type`, the inheritance column, every `json` / `jsonb` payload, whichever column holds a position, and `created_at` / `updated_at`, which come last whatever order they are named in. One name or a list |
| `recourse_hidden` | `[]` | columns kept off every screen — the table, the show page, the form (which also stops permitting them) and the search box. One name or a list: `def recourse_hidden = :name` and `%i[name title]` both read |
| `recourse_comment` | the column's own SQL comment | what a column is for, drawn under its field on a form. Nil on an adapter that keeps no comments — SQLite is one — so a host there answers it by hand |
| `recourse_broadcasts?` | `true` | whether saving a record refreshes every open index listing it — see [Live index refreshes](#live-index-refreshes) |

Overriding one means overriding a class method, which is what the `Recoursive`
concern next to the model is for:

```ruby
# app/models/zip/recoursive.rb
class ZIP
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      def recourse_order = :code
    end
  end
end
```

```ruby
# app/models/zip.rb
class ZIP < ApplicationRecord
  include Recoursive
end
```

`recourse_label` has to name a real column rather than a method, since it is
`select`ed alongside the id. Pick an encrypted column and its plaintext is what
the label reads — on every page that references the model, not just the form.

The engine extends every model with `Recourse::Searchable` too, loaded right
after Ransack so its `extend` lands ahead of Ransack's own defaults in the
singleton ancestor chain — ours win. These are the hooks behind a sortable
heading, a search box and a filter:

| Method | Default | What it decides |
| --- | --- | --- |
| `ransackable_attributes` | every column but the encrypted ones, plus any encrypted column a search can match whole | which columns a search or a filter may read |
| `ransackable_associations` | the foreign keys the search box reaches through | which other tables a predicate may join |
| `ransortable_attributes` | the timestamps, every column an index covers and every counter cache, less every foreign key | which headings can be clicked to sort |
| `search_field` | every indexed string column a table shows, plus the label behind every foreign key whose model is too long to list, ORed and matched on containment — or, for a model with none of those, its deterministically encrypted indexed columns, matched whole | what the search box searches — nil where there is nothing to look through, and no search box either |
| `search_prompt` | `Filter by`, then those same columns joined by `or`, in lower case but for the acronyms | what the search box says while it is empty |
| `filter_fields` | one `_in` entry per enum, then one per `belongs_to`, less the ones the search box reaches through | which columns get a filter, and what draws each |
| `recourse_listable?` | true when the table holds no more than `MENU_LIMIT` rows | whether a foreign key pointing here gets a menu or joins the search |

A `State` answers `'code_or_fips_or_name_cont'` for the first and `'Filter by
code or fips or name'` for the second, since `code`, `fips` and `name` are its
only columns that are both indexed and a searchable type — a string, text,
citext or enum, an enum's value being a word even though its own Postgres type
is not. An index is the only signal a schema carries about which column
identifies a row rather than describes it, so that is what both hooks read. The
prompt reads in lower case, except for the words Rails was told are acronyms:
`/locations` prompts `Filter by ZIP code`, not `filter by zip code`. Everything
the gem lower-cases goes through `Recourse.downcase`, which leaves a registered
acronym as it found it — the same call behind `No ZIPs.` and `All ZIPs`.

Register the singular only. `inflect.acronym 'ZIP'` is the whole of what a host
has to say: every plural the gem writes is its model's own name pluralized —
`ZIP.model_name.human.pluralize` — so the sidebar entry, the breadcrumb, the page
title and the tab all read `ZIPs` without `ZIPs` being registered as a word of
its own. Registering it would rename what Rails computes from the `zips` path
instead, down to `ZIPsController` and a `create_zips.rb` migration that has to
define `CreateZIPs`. The gem takes the labels and leaves Rails its own names.
Reading a title off the model has a second effect worth knowing: rename the model
in a locale file, under `activerecord.models`, and every one of those labels
follows.

Five of those seven hooks are yours. `search_field` and `search_prompt` are the
gem's own working: they are derived from the rest, and they are written down here
so you can see what a page will do, not so a model can answer them differently.
Their shape moves when the gem's does. A model that wants something else searched
changes what the schema says — an index is the signal both hooks read — and one
that wants a control of its own draws it with a `filter_fields` entry.

That extension is global, and worth knowing before you write a search of your
own: every model in the app answers `ransackable_attributes`, whether or not a
`recourses` line ever names it. Ransack's own default allows nothing until a
model opts in, and the gem replaces that default with every column but the
encrypted ones. So a `Model.ransack(params[:q])` you write inherits the same
allowance, and a request can filter on any column the model has. Narrow it in the
model where that is more than you meant to offer.

A foreign key is the other half of what a search looks through, and what decides
is how long the other table is. A menu is a control while every row fits in one;
past that it is a page of HTML nobody reads. So a `belongs_to` whose model is not
`recourse_listable?` — more than `MENU_LIMIT`, which is 100 — gets no filter, and
its label joins the search instead. `/locations` answers `'zip_code_cont'` for
40,965 ZIPs; `/zips` answers `'code_or_county_name_cont'` for 3,144 counties and
keeps the menu for its markets. Each names that one association in
`ransackable_associations`, so exactly the join being searched is allowed.

A model whose only searchable columns are encrypted is searched differently, and
`/agents` is the case: an email is encrypted, so a `cont` would read ciphertext
and match nothing. Where a model has no plaintext column worth searching, the
search box asks for a whole value instead — `email_eq`, prompted `Filter by exact
email` — which works because Active Record encrypts the term the same way it
encrypted the column. Only *deterministically* encrypted columns qualify: without
`deterministic: true` two writes of one address are two different ciphertexts, so
nothing would ever compare equal. Sorting is never offered on any of them, since
what an ORDER BY would sort is the ciphertext.

The label has to be a word for that to mean anything — a string, text, citext or
enum — since a `cont` against an id or a date matches nothing. A model too long
to list whose label is neither leaves the foreign key with no filter and no
search, and `scope:` on a `filter_fields` entry is what draws a menu for it
anyway.

No foreign key's column is sortable, these included: the cell shows a label from
another table, and the id under it is not the order that label reads in.

`recourse_listable?` counts once per class and counts no further than it has to —
`LIMIT 101` — so the question costs 0.03ms whether the table holds ten rows or
ten million. A table that crosses the line is noticed at the next boot.

Overriding one is the same shape as `Recoursive`: a same-named concern beside
the model, defining inside `class_methods do`. A `Market` that renames the filter
it is narrowed with, and keeps a timestamp out of its sortable headings:

```ruby
# app/models/market/searchable.rb
class Market
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def ransortable_attributes(auth = nil) = super - ['audited_at']

      def filter_fields = { 'state_id_in' => { label: 'Home state' } }
    end
  end
end
```

```ruby
# app/models/market.rb
class Market < ApplicationRecord
  include Searchable
end
```

## What a field becomes

Two questions split the two kinds of foreign key, and either one sends it to a
text field. `recourse_typed_label?` asks whether the label is bounded — a length
validator — and so can be typed: a ZIP code can. `recourse_listable?` asks
whether the table is short enough that a menu of every row is a control rather
than a page: 3,144 counties are not. A county name answers no to the first and
still gets a text field through the second, which is the same call the filter
beside it makes.

Either way the field asks for the label under the foreign key's own name, and
the controller looks the record up on the way in — `ZIP.find_by code: '90210'` —
so no model needs a virtual attribute and no strong parameter needs a special
case.

The field names the attribute it wants typed — `ZIP code`, not `ZIP` — since a
box has to say what goes in it. A heading does not: the table and the show page
call the column what it is, `ZIP`, because nothing is typed under one and
`Location address line 1` over a column of addresses reads as a question asked
where there is no form.

| Column | Field |
| --- | --- |
| a foreign key whose label is typed, or whose table is too long to list | text field, resolved to an id on submit |
| any other foreign key | a searchable combobox of every record, by label |
| a counter cache | none: Rails keeps it, so no form offers it and `create` does not permit it |
| `phone` | telephone field, typing its own separators as it goes |
| an encrypted attribute | the field its kind earns, prefilled — ciphertext is not a kind |
| `email` | email field |
| a `boolean` | checkbox, under its label like every other control |
| an `enum` | a combobox of the words it admits, one at a time |
| an `integer` | number field, `step="1"` |
| a `float` | number field, `step="any"` |
| a `decimal` | number field stepped by its scale and capped by its precision — `scale: 2, precision: 4` gives `step="0.01" max="99.99"` |
| a `:monetary` | the same, with the currency in a `.form-adorn-text` before it |
| a `:percentage` | the same, with `%` after it, through `.form-adorn-end` |
| a `:time_zone` | a combobox of the zones its type admits, opening on the few it calls common |
| a `date` or `datetime` attribute | date or `datetime-local` field |
| anything else | text field |

The type comes from the model's own `type_for_attribute`, so an `attribute
:opens_on, :date` override counts, and so do its `precision` and `scale` —
`columns_hash` is never asked.

`:monetary`, `:percentage`, `:month`, `:year` and `:time_zone` are types your app defines, not hooks
this gem asks for. A `decimal` says how many digits it keeps and nothing about what they mean,
so if you want `$95.00` and `15.00%` on your pages, register the types that say
so:

```ruby
# app/types/money.rb
class Monetary < ActiveRecord::Type::Decimal
  PRECISION = 10
  SCALE = 2

  def initialize(precision: PRECISION, scale: SCALE, **) = super
  def type = :monetary
end

# config/initializers/types.rb
ActiveSupport.on_load :active_record do
  ActiveRecord::Type.register(:monetary) { |_name, **options| Monetary.new(**options) }
end

# and in the model
attribute :hourly_rate, :monetary
```

A `:time_zone` is the same idea over a string: the column holds words like
`Eastern Time (US & Canada)`, which are spelled exactly or not at all, so the
field is a menu rather than a box. Say only that a column holds one and the menu
is every zone Rails knows:

```ruby
class Zone < ActiveRecord::Type::String
  def type = :time_zone
end
```

Most apps admit fewer, and a menu of a hundred and sixty-five is a page to read
rather than a control. Two more answers narrow it, and the type is where they
belong — it is already what the gem asks whether a column holds a zone at all:

```ruby
class Zone < ActiveRecord::Type::String
  ZONES = ActiveSupport::TimeZone.us_zones.map(&:name).freeze
  COMMON = ['Eastern Time (US & Canada)', 'Central Time (US & Canada)',
            'Mountain Time (US & Canada)', 'Pacific Time (US & Canada)'].freeze

  def type = :time_zone
  def values = ZONES   # what the menu offers at all
  def common = COMMON  # what it opens on
end
```

The rest wait behind `All time zones`, the way a filter's unused options do — and
the record's own zone is shown whether or not it is common, since a box must not
name a value its menu does not offer. Validate against the same constant and the
two cannot drift: `validates :time_zone, inclusion: { in: Zone::ZONES }`.

`:monetary` rather than `:money`, which is a native type on PostgreSQL: Rails
raises `TypeConflictError` rather than let an app shadow an adapter's own, and
`override: true` would be the price of a word there is no need to take. The
class is another matter — `Monetary` above is only what this example calls it.

The gem asks the attribute what it is and formats what it hears, so a type of
your own is all it takes. What it hears is `def type`, not the class's name nor
the name the type was registered under: any class reporting `:monetary` is drawn
as money. Give migrations the same word by extending
`ActiveRecord::ConnectionAdapters::TableDefinition` — Rails keeps
`define_column_methods` private, so write the method out:

```ruby
module MonetaryColumns
  def monetary(*names, **options)
    names.each { |name| decimal name, precision: Monetary::PRECISION, scale: Monetary::SCALE, **options }
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include MonetaryColumns
```

Then `t.monetary :hourly_rate` and `attribute :hourly_rate, :monetary` are the same
decision said twice, once to the database and once to the page. `test/dummy` does
all of this, for all four.

A `:month` is the number of one and reads as `August`; a `:year` is digits and reads
as `2025` rather than `2,025`, a year counting nothing. Both take a whole-number
step in a form. What either may *be* is your app's: a type cannot validate, so a
concern that declares the attribute and validates its range — and a `t.month` column
method writing the check constraint — is what says it once.

A phone is a phone before it is ciphertext: an encrypted `phone` gets the
telephone field, which types its own separators as you go. Encryption settles what
the database keeps, not what a form may show. The show page still masks it.

What the browser then enforces is read from the validators, never from the
schema: `maxlength` and `minlength` from a length validator, `pattern` from a
format validator's regexp with its anchors removed, `required` from a presence
validator on the column or on the association, a numeric `inputmode` where the
pattern admits only digits. A field with a pattern also gets a `title` naming a
value that would match, and an optional field gets `Optional` as its
placeholder. A constraint your database has and your model does not is a
constraint no field can show.

## Sorting, searching and filtering

A heading sorts its own column when the model's `ransortable_attributes`
allows it. The row partial draws every heading through `sort_header(name)`
rather than a bare title:

```erb
<%= column header: sort_header('name') do %>
  <%= resource_cell record, 'name' %>
<% end %>
```

It returns a sort link only on the header pass, with its own caret — up for
ascending, down for descending, none where nobody sorted by that column — and
the plain title on every other pass, so a `<td>`'s `data-cell` stays readable
text. The link restarts the table at its first page, since a sort keeps
whatever the request was already searching or filtering by and only replaces
the order.

The index builds a GET form — a search box for the model's `search_field`, one
filter per `filter_fields` entry, nothing at all where the model offers neither —
and puts it in `content_for :search` rather than drawing it anywhere. The
gem's layout yields it in the navbar, to the right of the breadcrumb and the
buttons; a layout of your own has to `yield :search` the same way it yields
`:actions`, or the form is built and never shown. A filter reuses the combobox from
"Comboboxes for foreign keys" with `multiple: true`, so a request can narrow a
table to more than one of what a foreign key points at — `?q[state_id_in]=1,2`
for two states at once.

Where the model a filter lists keeps a counter cache of the rows being filtered —
`markets.zips_count` on `/zips` — every option in that menu ends with the count, at
the right of its row and in muted text and in the menu alone: a closed box showing
one chosen option reads its name and nothing else. The menu is ordered by that count rather
than by name: the choice most of the rows are behind is the first offered, with the
name breaking a tie. A menu with no count to read is still ordered by name. An option counting none of them is in the
menu without being on it: `d-none` until the `All markets` line at the top is
clicked, which reveals every one of them as well as unticking whatever was ticked.
One already ticked stays visible either way, or the box would name a filter its own
menu does not offer. It comes from the same
`recourse_counters` the table's own headings read, so a `zips_count` nobody
maintains is not mistaken for a count of anything, and it is fetched by widening
the two-column `SELECT` the menu already makes rather than by a query of its own.

Every enum gets one too, and gets it first: `/bookings` opens with a `Status`
menu of the words that column admits, `?q[status_in]=scheduled,fulfilled` for two
of them at once. The words are the model's own `defined_enums`, the same ones the
form's menu offers and a show page draws as a badge, and the way back reads `All
statuses` — the column's name rather than a model's, since a status belongs to the
table being read and not to another one. A foreign key whose model is too long to list — the ZIP
on `/locations`, the county on `/zips` — is offered no filter at all, since the
menu would be the whole table. Its label goes into the search box instead:
`?q[zip_code_cont]=005` narrows one page by joining `zips`, and
`?q[code_or_county_name_cont]=Autauga` narrows the other by joining `counties`.
Naming that predicate in `filter_fields` with a `scope:` still offers a menu,
over whichever relation the scope names.

A third shape covers a predicate no column of the model describes: `values:` names
the menu's options outright. The entry needs a `label:`, since there is no column
to take a heading from, and each option is a `[label, value]` pair — the words it
reads as, and what a tick submits — with a bare word standing as both. A provider's
CRM is the case, kept as the type of a `has_one` rather than as a column here:

```ruby
# app/models/provider/searchable.rb
class Provider
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def ransackable_associations(auth = nil) = super + ['integration']

      def filter_fields
        crms = [Integration::Jobber, Integration::HousecallPro]
        values = crms.map { |one| [one.model_name.human, one.name] }

        super.merge 'integration_type_in' => { label: 'CRM', values: values }
      end
    end
  end
end
```

`?q[integration_type_in]=Integration::Jobber` is what a tick submits, and the way
back reads `All CRMs`, after the label. A value is compared as text, since that is
what a request carries it back as, so a number or a symbol named here still reads
as ticked once it is picked. The predicate goes through Ransack like any
other, so a `values:` filter reaching across an association needs that association
in `ransackable_associations` — `integration` above — the same allowlist the search
box's own joins are named in.

Typing in the search box, or picking from a filter's menu, submits the form
itself — a Stimulus controller resubmits 300ms after the last keystroke, and
immediately on every option ticked or unticked. Only the table and its
pagination are replaced by the answer: they sit in a `<turbo-frame id='results'>`
that the form targets, so an open menu stays open, the caret stays where it was
typing, and the address bar still advances to the query that produced the table.
Without Turbo the same form is an ordinary GET that reloads the page, and the
caret is put back into the search box by hand.

What a search matched is marked in the cell that matched it, so twenty rows that
all matched still say why each one did. Only the columns the search looked
through are marked — including the label behind a foreign key it reached
through, so `/locations` marks the ZIP code. A row partial of your own gets the
same by calling `search_highlight`.

Links need to know about that frame. A heading's sort and a pagination link
navigate it, which is the point of it — and that sort is read back off the URL
into the form's hidden `q[s]`, so the next search keeps the order the last click
asked for. **Every other link in a table has to leave the frame**, since the page
it goes to has no frame of that name and Turbo would answer `Content missing`.
The edit pencil does; a row partial of your own should use `turbo_link_to`, which
is `link_to` with `data-turbo-frame='_top'` already on it:

```erb
<%= column header: 'Name' do %>
  <%= turbo_link_to contact.name, contact_messages_path(contact) %>
<% end %>
```

A model overrides any of this in its own `Searchable` concern; see "What a
model can say".

What this costs:

- A search reads the whole table: a `cont` predicate is `ILIKE '%…%'`, which
  cannot use a btree index.
- A filter's combobox selects every row of the model it offers, which is what
  the typed-label rule and a `scope:` are both for.
- A search that reaches through a foreign key joins that table, and the
  containment is never indexed there either. Which side the planner drives from
  decides the cost: with few rows on this side it index-scans the other and
  tests each match, and with many it scans the other table once and hashes.
- A sort Ransack applies has no tiebreaker, so rows tied on the sorted column
  can shuffle between pages.
- Pagy's own count runs on the filtered relation, so a narrower filter is a
  cheaper count too, not just a shorter table.

## Live index refreshes

When the host app runs [turbo-rails](https://github.com/hotwired/turbo-rails),
an index page subscribes to its model's refreshes: save a record in one browser
and every other browser with that index open redraws the table in place, scroll
and half-typed search intact, with the filters and sort it was showing. Nothing
to declare — every recoursed model broadcasts by default, and a model that
should not says so in its `Recoursive` concern:

```ruby
class_methods do
  # A toggle flips too often to be worth refreshing every open screen for.
  def recourse_broadcasts? = false
end
```

What the host needs beyond turbo-rails itself, which is a dependency: Action
Cable mounted with a real adapter in production (and
`config.action_cable.allowed_request_origins` set), and an Active Job backend —
refreshes are broadcast through `broadcast_refresh_later_to`, so a job adapter
that is down means pages that quietly stop refreshing. Every page is served
turbo-rails' own Turbo bundle, so the cable element and the signed streams come
from the same gem version.

Broadcasts attach the first time a model's
recourse is served in a process; a process that changes records without ever
serving one — a job runner, a console — does not broadcast unless the model
declares `broadcasts_refreshes_to` itself.

## Overriding a screen

Anything your app defines wins, because your app's view paths come first and
`define_missing` steps aside for a controller that already exists.

| Define this | To replace |
| --- | --- |
| `app/controllers/contacts_controller.rb` | the whole controller |
| `app/controllers/recourses_controller.rb` | what every recoursed controller inherits — authentication above all |
| `app/views/contacts/index.html.erb` | the index template — `show`, `new` and `edit` the same way |
| `app/views/contacts/_row.html.erb` | the cells of one row |
| `app/views/contacts/_fields.html.erb` | the fields of the form |
| `app/views/recourses/_card.html.erb` | the tabbed card the show and edit pages sit in |
| `app/views/recourses/_sidebar.html.erb` | a shared partial, for every resource at once |

Three private methods on a controller of yours are the seams for a screen the gem
otherwise draws whole. `recourse_relation` says which rows an index lists, and
nothing narrows an answer of its own. `recourse_position` says which column those
rows are dragged into order by, where it is not the one the model nominates — see
[A table somebody arranged](#a-table-somebody-arranged). `recourse_model` says
which model the screen is about, where the route's name is not one: a page of `neighbors` lists what a
measurement answers rather than what a table holds, so it is named for the answer
and there is no `Neighbor` class to find.

```ruby
class NeighborsController < Admin::Locations::RecoursesController
private

  def recourse_model = Location
  def recourse_relation = Location.near @recourse_parent
end
```

The local a row partial receives is still named after the route — `neighbor:` — so
what a page is called and what it lists stay two separate things.

No cache stands in the way. The index table renders inside a fragment, and its
key carries the digest of whichever `_row` the lookup resolved — so a row
partial added, edited or deleted expires the table by itself, with nothing to
clear. The digest is Action View's own, so it follows what that row renders from
inside as well: a partial two levels down expires the table the same way its row
does.

Templates are looked up under `contacts/`, then `recourses/`, then
`application/`, since those are the controller's prefixes. That is what lets a
partial be replaced for one resource or for all of them — and it is why a
controller of your own should subclass `RecoursesController` if it wants to keep
the gem's views. A controller inheriting straight from `ApplicationController`
has no `recourses/` prefix, so it finds none of them.

A template of yours can still call the gem's partials:

```erb
<% content_for :title, 'States' %>

<%= render 'table', recourses: @resources, pagy: @pagy %>
```

A row partial is rendered once for the header row and once per record. It
declares the record as a strict local, under the singular name of the resource,
and builds its cells with `column`:

```erb
<%# locals: (contact:) -%>
<%= column header: 'Name' do %>
  <%= contact.name %>
<% end %>

<%= column header: 'Created at', class: 'text-nowrap' do %>
  <%= resource_cell contact, 'created_at' %>
<% end %>
```

`column` draws a `<th>` on the header pass and a `<td>` on every other, and its
block runs only for a real record — which is why `contact` arriving as `nil`
for the header row is not a problem.

A fields partial is the same shape, and builds its fields with `field`. Pass
`label:` to override the heading, and `type:` to override the field the column
would have chosen:

```erb
<%# locals: (contact:) -%>
<%= field :phone, type: :phone %>
<%= field :email, type: :email %>
<%= field :name, label: 'First name' %>
<%= field :surname, label: 'Last name' %>
```

The form builder is not a local — it reaches `field` through `@recourse_form`,
so `field :phone` is all the call site has to say.

A values partial is the same shape again, for the show page, and builds its rows
with `value`. It needs no builder at all, so `label:` is the only option:

```erb
<%# locals: (contact:) -%>
<%= value :name, label: 'First name' %>
<%= value :phone %>
```

## Behavior on every screen, authentication above all

The screens are served by two classes, in the relation `ActionController::Base`
and `ApplicationController` have: `Recourse::BaseController` holds every action,
filter and helper the gem provides, and `RecoursesController` inherits it and
adds nothing. Every recoursed controller descends from the second one, so that
is the seam — define it in your own app and your copy wins, since your
`app/controllers` comes before any engine's:

```ruby
# app/controllers/recourses_controller.rb
class RecoursesController < Recourse::BaseController
  before_action :authenticate_agent!
end
```

Every screen the gem serves now requires a signed-in agent — the ones whose
controllers the gem defines as much as the ones you wrote, since
`ContactsController < RecoursesController` either way. Nothing else changes:
the actions, the strong parameters and the view prefixes all come from the base
class, so a file of four lines costs you none of them.

Keep the class named `RecoursesController`. Its name is what puts the gem's own
templates under the `recourses/` prefix, so a differently named class of your
own would find none of them.

An `ApplicationController` filter reaches the screens too, since
`Recourse::BaseController` inherits from it like the rest of your app. Redefining
`RecoursesController` is for what only the administered screens should do —
which is the usual shape of an admin area, and what a host with a public site in
the same app needs.

## Rewording anything it says

Every string the gem renders comes from `config/locales/recourse.en.yml` under
the `recourse` key, so rewording one takes a locale file of your own rather than
a reopened helper:

```yaml
# config/locales/en.yml
en:
  recourse:
    add: Create a new %{model}
    none: "Nothing here yet."
    select: Select an airplane…
```

The model's own name is `%{model}` and its plural `%{models}`, and both come from
`model_name.human` — so translating `activerecord.models.contact` renames it
everywhere at once, in the button and the flash alike.

The gem's own copy carries no `a` or `an` anywhere it interpolates a model,
because which one is right depends on how the word sounds rather than how it is
spelled — *an hour*, *a user*, *a ZIP*, *an SMS* — and no rule gets that right in
every language a key might be translated into. `Select…` says as much as `Select
a State…` under a label that already reads `State`. If your models all take the
same article, the keys above are where you say so.

## Cloning a record

A record's own page carries a `Clone` link beside the breadcrumbs, wherever the
resource draws a `new` form for it to open:

```
/places/5   ->   Clone   ->   /places/new?cloned_id=5
```

That is the ordinary new form with a seed, not a page of its own — the same title,
the same trail, the same fields, and a submit landing on the same `create`. Every
value the record can lend arrives filled in, so making another one like it is a
matter of changing what differs.

What it will not lend is a value no second row could hold. A column validated
unique with no scope opens empty:

```ruby
class Place < ApplicationRecord
  validates :name, presence: true                    # copied
  validates :slug, presence: true, uniqueness: true  # left for the reader
end
```

Read off the validators rather than off the indexes, so what the browser is asked
for is what the model will actually enforce. A `uniqueness:` carrying a `scope:` is
copied instead — what makes that pair unique is the scope, which the reader is free
to change.

### What comes with it

A record is not always one row, and `recourse_cloned` is where a model says which of
its associations are part of it:

```ruby
class Place < ApplicationRecord
  def self.recourse_cloned = %i[audit seal photos]
end
```

Named there, an association is carried; unnamed, it stays behind. Nothing is
guessed — `dependent: :destroy` is not the signal, because it answers a different
question. It says what may not *outlive* the parent, where cloning asks what is
*part* of it, and the two come apart constantly: a bookmark dies with the row it
keeps and is still the reader's rather than the row's.

One list, three behaviors, each read off the association's own kind:

| Declared as | What the copy gets |
| --- | --- |
| `has_many` / `has_one` | new records, copied the same way, all the way down |
| `has_and_belongs_to_many` | the same records, joined again |
| `has_many_attached` / `has_one_attached` | the same files, attached again — nothing is re-uploaded |

Because a child is copied by asking it for its own copy, a model deep in the tree
declares only its own children, and the recursion is the gem's:

```ruby
class Provider < ApplicationRecord
  def self.recourse_cloned = %i[notions reviews departments photos]
end

class Department < ApplicationRecord
  def self.recourse_cloned = %i[strengths services image]
end
```

At every level the copy is cleared of what no second row may inherit: the primary
key, `created_at` and `updated_at`, every counter cache, and every unscoped-unique
column. So a counter starts at zero rather than at the source's total, and a clone
does not claim the age of what it copied.

A position is cleared once, on the record the reader asked for: it lands last in its
arranged table rather than on top of the row it was copied from. The copies under it
keep the places they were in — their siblings are the copies beside them, and the
order somebody put those in is part of what was copied.

Anything a list cannot express is an override, and `super` does the rest:

```ruby
class Department < ApplicationRecord
  # `dup` copies this key, and it would point at the plan of the provider we copied.
  def recourse_deep_clone
    super.tap { |copy| copy.promoted_plan_id = nil }
  end
end
```

The whole graph is built unsaved and written in one transaction, so a copy either
arrives complete or does not arrive.

Since the fields on the form are the record's own columns, what a model names is
carried out of sight — so the form says so, counting what is coming the way the
delete warning counts what is going:

```
Its audit, its seal, and 2 photos will be copied too.
```

Nothing at all for a model that names none, and nothing is written until the form is
submitted. An id naming no record answers 404, the way it does on any other page.

## Bookmarking a row

```ruby
# config/initializers/recourse.rb
Recourse.bookmarks = -> { Reminder.where agent: Current.agent }
```

One line says how a bookmark is stored, and every table whose model can hold one
opens with a square: hollow where whoever is looking has not kept that row,
filled where they have, and the kept rows sorted to the top.

The other half is a `has_many` the model owes Rails anyway:

```ruby
# app/models/provider.rb
has_many :reminders, as: :topic, dependent: :destroy
```

That association *is* the opt-in. A model that declares none cannot hold a
bookmark, so its table opens where it always did — no routes option and nothing
to say twice.

Nothing is assumed about the shape of the bookmark. The gem reads the model's own
association rather than introspecting the class behind it, so Rails' reflection
answers everything: `foreign_key` names the column, `type` names the type column
where the association is polymorphic and is nil where it is not, and
`polymorphic_name` is the value — resolved through `base_class`, so a subclass
stays filed with the table it shares. A bookmark table holding a plain
`provider_id` and no type column works the same way.

A Proc is the shape to declare it in. A relation written here would hold whoever
was signed in when the process booted, which is nobody; the Proc is resolved once
per request instead. A relation or a model class is accepted for the case where
nobody in particular is looking.

Clicking a square writes the row and answers before the server does: the icon
flips, the request goes in the background, and the table is never redrawn — so
the row stays where the eye left it until the next real page load, which is where
the kept-first order takes effect. Without JavaScript the same button submits,
redirects and says `Bookmark added.`, which is the floor every button here
degrades to. Either way the row is written by `BookmarksController`, which a host
overrides the way it overrides `RecoursesController`.

## Light or dark

The sidebar ends with one control: a moon while the page is light and a sun while it
is dark, at the foot of the sidebar wherever it is a column. The icon names where a
click goes rather than where the page is. The choice belongs to the reader, so it is
kept in their browser under `localStorage['recourse-scheme']` and put back on the next
visit, by an inline script in the `<head>` before the first paint.

The mode is forced with `data-bs-theme` on the `<html>` element — Bootstrap's own
attribute, which sets `color-scheme` and so decides every `light-dark()` on the page.
Until a reader clicks, no attribute is set at all and the page follows their system.

## Helpers

`RecoursesController` does `helper Recourse::Helpers`, so these are available in
any template or partial it renders. A controller of your own that does not
subclass it can include the module the same way.

Naming the resource on the page:

- `resources_name` — `'Contacts'`
- `resource_name` — `'contact'`
- `resource_key` — `:contact`, the local a row or fields partial receives
- `resource_record` — the record the action built, read from the assigns
- `resource_record_label` — what that record is called, by its model's label

Building a table:

- `column(header:, **, &)` — one cell, a heading on the header pass
- `resource_columns` — the columns a table shows
- `resource_column_title(column)` — a heading, translatable like any attribute
- `resource_cell(record, column)` — one value, formatted by what it holds
- `search_highlight(value, column)` — that value with the current search marked
  in it, where the search looked through that column at all
- `sort_header(column, title = nil)` — a heading that sorts by that column
  where the model allows it, the plain title otherwise. It calls Ransack's
  `sort_link` rather than replacing it, so that helper stays yours to use

Searching and filtering:

- `search_form` — the search and filter form, or nothing where the model offers
  neither a search field nor a filter. The index hands it to `content_for
  :search`, so a layout is what decides where it goes
- `filter_field(predicate, label: nil, scope: nil, values: nil)` — one filter, a
  multiple combobox of the records a foreign key points at, of the values a column
  admits, or of the `[label, value]` pairs `values:` names

Reading one out:

- `value(name, label: nil)` — one labelled value in the show page's grid, the
  heading a form would give the column above what the record says below
- `resource_value(column)` — that value alone, an em dash where there is none.
  `value` is what masks an encrypted one; this is the value itself
- `formatted_value(column)` — the value formatted by what the column holds, with
  no em dash and no mask
- `attribute_kind(column)` — what the column holds, as `:counter`, `:monetary`,
  `:percentage`, `:enum`, `:phone` or the attribute's own type. The one question
  the show page and the form both answer
- `icon_tag(concept, label: nil)` — one Bootstrap icon, by the concept Unicon
  names it under rather than by what this set happens to call it

Building a form:

- `field(name, label: nil, type: nil)` — one labelled field in the grid
- `editable_columns` — the columns a form offers
- `resource_field(form, column, type: nil)` — the field alone, unlabelled
- `kind_field(form, column, **options)` — the field a column's kind deserves, which
  is what `resource_field` falls through to
- `combobox(form, column, association)` — the menu a foreign key offers
- `field_html(column, type = nil, model = resource_model)` — the browser-side
  constraints a column's validators add up to
- `pattern_example(pattern)` — a value the pattern would accept

Foreign keys:

- `belongs_to_association(column)` — the association a column is the key of
- `reference_field`, `reference_cell`, `reference_title` — the field, the value
  and the heading for one

Chrome:

- `resource_breadcrumbs` — the trail to this page, as `[title, path]` pairs
- `sidebar_resources` — every declared resource with an index, in routes order,
  each with the position of the letter that reaches it from the keyboard
- `current_resource?(name)` — whether a sidebar entry is this page
- `resource_label(resource, title, key = nil)` — the icon its model picked and a
  title, for a link to a resource, with the letter at `key` marked as its
  keyboard shortcut
- `new_resource_path`, `show_resource_link(record)`, `edit_resource_link(record)`,
  `destroy_resource_button(record)` — nil and nothing when the action is not
  defined or not routed, so a link never points at a `404`
- `resource_links(record)` — both row links together, or nothing where a row has
  neither; `resource_actions?` is what the table asks before drawing the column
- `resource_tabs(record)` — the pages a record has as `[label, path, current]`, which
  is what the card's header draws
- `destroy_warning(record)` — the text that button asks for confirmation with
- `turbo_link_to(name, path, **options)` — `link_to` for a link inside a table,
  carrying the `data-turbo-frame='_top'` that takes it out of the results frame
- `flash_theme(key)` — the Bootstrap theme one flash entry reads in

## What the engine serves

The gem vendors what its pages cannot render without and serves it from
`/recourse/` through `Rack::Static`, so a host needs no asset pipeline:
`bootstrap.min.css`, `bootstrap-icons.min.css` with its fonts,
`bootstrap.bundle.min.js`, `stimulus.js`, and the gem's own Stimulus
controllers — `clear`, `deselect`, `phone`, `reveal`, `search` and `shortcuts`.

It also ships `app/views/layouts/recourses.html.erb`, and that is the layout its
screens render in — yours is not involved. `RecoursesController` implies
`layouts/recourses`, which Rails finds in the gem before it falls through to
`layouts/application`, so the screens arrive styled in an app that has done nothing
but draw a route: the stylesheets, the Stimulus controllers, the navbar, the
sidebar and the search slot are all the gem's to place.

Two ways to put your own chrome back, where an admin page should carry it:

```erb
<%# app/views/layouts/recourses.html.erb — yours wins, being earlier in the view paths %>
<%= render template: 'layouts/application' %>
```

```ruby
# or a controller of your own, which keeps everything else the gem defines
class ContactsController < RecoursesController
  layout 'application'
end
```

Either way the screens are then inside your layout, which has to link the two
stylesheets from `/recourse/`, register the Stimulus controllers, and yield what
the screens contribute: `yield :title`, `yield :actions` and `yield :search`.

Named `recourses` rather than `application` on purpose. A gem shipping
`layouts/application` is a layout an app with none of its own would render *its own*
pages in — the engine's view paths answer for `layouts/application` as readily as
for anything else — and this one is a navbar and a sidebar for someone else's admin
screens.

The index table renders inside a `cache_if params[:q].blank?, recourses`
block, so a sorted or filtered table is drawn live instead of cached — two
requests can share a relation and still want different headings. A
combobox's list of options renders inside `cache [recourses, multiple,
selected]`, since the same relation is different markup as a single form
combobox and as a multiple filter, and the same menu is different markup
again with a different selection. Configuring a cache store is what turns
what is cached from correct into cheap.

## Ruby API

Everything below is what a host app may call, and the list is drawn from what
host apps do call. Anything else the gem defines is private — not because Ruby
will stop you (a template reaches a private helper the same as a public one),
but because it is the gem's own working and moves without notice.

Drawn in `config/routes.rb`:

- `recourses :contacts` — the DSL, taking everything `resources` takes,
  including `only:`, `param:`, `constraints:`, several names at once, and a
  block that nests

Written in an initializer:

- `Recourse.bookmarks` / `Recourse.bookmarks=` — how a viewer's bookmarks are
  stored, as a Proc answering their rows; nil for no bookmarks anywhere
- `Recourse.color` / `Recourse.color=` — the Bootstrap color family the pages
  call primary, one of `Recourse::COLORS`, or nil for Bootstrap's own blue
- `Recourse::COLORS` — `%i[blue gray orange purple pink brown]`


Declared on a model, each overriding a default:

- `recourse_label` — the column a record is named by
- `recourse_hidden` — a column, or a list of them, no screen shows
- `recourse_displayed` — a column, or a list of them, a table draws anyway; how
  `created_at` and `updated_at` are asked for
- `recourse_order` — how an index sorts before anyone clicks a heading

Subclassed or reopened in `app/controllers`:

- `BookmarksController` — what writes and drops the row behind a bookmark square
- `RecoursesController` — what every generated controller inherits, and what to
  reopen to add a `before_action` of your own
- `Recourse::BaseController` — what that inherits, holding all seven actions

Called from a template of your own:

- `column(header:, **, &)` — one cell, drawn as a heading in the header row and
  as the block's output in every other
- `sort_header(column, title = nil)` — a heading that sorts by its column
- `search_highlight(value, column)` — a value with the searched text marked

And what a failure is:

- `Recourse::Error` — the class every failure the gem reports will be, so a host
  can rescue one type

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests, or `rake` to run the tests and RuboCop. You can
also run `bin/console` for an interactive prompt.

The test suite boots a dummy Rails app against SQLite, so there is no server to
run: the database is a file under `test/dummy/storage`, created and migrated on
the first run, and deleting it is the reset. SQLite is the dummy app's choice,
not the gem's — nothing in the gem names an adapter, so a host running
PostgreSQL or MySQL is served the same screens. What follows from a column kind
only one adapter has follows only there — a citext column, say — and everything
else is read through Active Record's own neutral answers.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/claudiob/recourse.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
