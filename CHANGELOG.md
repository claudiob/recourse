# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## Unreleased

* [Feature] A filter over the words a host names

  A `filter_fields` entry tried a column of the model and then a foreign key, and one
  that was neither was dropped without a word. `values:` is the third shape: the menu's
  options said outright, for a predicate the schema describes nothing about — the type
  behind a `has_one`, say. The entry carries a `label:`, since there is no column to
  head it, and each option is a `[label, value]` pair — the words read, the value
  submitted — with a bare word standing as both, which is what an enum's and a
  boolean's own values already are.

      def filter_fields
        crms = [Integration::Jobber, Integration::HousecallPro]
        values = crms.map { |one| [one.model_name.human, one.name] }

        super.merge 'integration_type_in' => { label: 'CRM', values: values }
      end

  The way back reads `All CRMs`, after the label — the same line an enum's menu draws
  after its column. And after its label where it has one: an enum or a boolean declared
  with a `label:` now names that line after the label rather than after the column, so
  a menu headed `Home state` says `All home states` rather than `All states`. The
  predicate goes through Ransack unchanged, so a filter reaching across an association
  still needs that association in `ransackable_associations`.

* [Fix] The delete dialog opens a second time on the same page

  A confirmed delete inside the results frame is a visit, and the visit disposed the
  dialog mid-close — which closed it, but left the `hiding` class its closing animation
  ran under. The next confirm opened it invisible. The class comes off with the dispose.

* [Feature] A menu with several picks names the first and counts the rest

  The plugin wrote `2 selected`, which says how many and not which. The toggle now
  reads `California + 1 more`, in the words the `more` locale key gives it, written over
  the plugin's text on every change and once the instance is made.

* [Feature] A table of places can be read as a map

  A model keeping a `google_place_id` earns a second shape for its index:
  `/counties.map` fills in each county of the page on a Google map, in the frame and
  over the footer the table has, so the search, the sort and the pages work the same
  on either. The footer under the table offers `Display as map` and the one under the
  map `Display as table`, each keeping the page the other was on. The key and the map
  are read from the host's credentials under `google_maps`, as `api_key` and
  `county_map_id`; the column is the whole opt-in. `.map` is registered as a name for
  HTML, and the index renders its HTML templates for it.

* [Feature] A menu narrowed by another

  A form picking a county wants a state box beside it, so the three thousand counties
  come down to the sixty of one state. The combobox partial takes `key:`, the column
  each option is narrowed by, and writes it on the option; the `narrow` Stimulus
  controller, on any ancestor of the two menus, reads the narrowing menu's own
  `change.bs.combobox` and holds back every option whose key is not the value picked:

      <%= form_with url: provider_counties_path(@provider), data: { controller: 'narrow' } do %>
        <div data-action='change.bs.combobox->narrow#pick'>
          <%= render 'recourses/combobox', name: nil, id: 'state', label: 'name',
                     recourses: State.select(:id, :name).order(:name),
                     none: t('recourse.all', models: 'states'), placeholder: t('recourse.select') %>
        </div>
        <%= render 'recourses/combobox', name: 'county[ids]', id: 'county_ids', multiple: true,
                   label: 'name', key: 'state_id', placeholder: t('recourse.select'),
                   recourses: County.select(:id, :name, :state_id).order(:name) %>
      <% end %>

  Held back with `d-none`, which the plugin's own search leaves alone. Picking the
  narrowing menu's `none` shows every option again; a multiple narrowing menu holds
  back whatever none of its picked values key, and nothing picked holds nothing back.

  And the partial takes `grouped:`, a column whose value heads each run of options —
  the state over its counties — so the rows want ordering by it first. A heading
  carries the key too, and goes with its options.

* [Fix] A nested resource that draws its own member pages links to them

  A nested table's Show and Edit were looked up above the nesting, at the resource's
  own top-level routes, since a nesting draws the collection actions and leaves the
  member pages to the resource. A resource that has no top-level pages — a county is
  read under the provider serving it and nowhere else — drew no links at all, however
  many member routes the host nested under the parent. Where the nesting routes `show`
  or `edit` itself, its rows now link there.

* [Fix] A table of a model with no timestamps is drawn each time

  `cache` reads `MAX(updated_at)` off the relation, and a model Rails keeps no
  timestamps on raised `PG::UndefinedColumn` on its first index. The menu already
  asked before caching; the table now asks the same question.

* [Feature] `recourse_extra_columns`, for a cell no column holds

  A page built from a route rather than read off a row — a band's checkout page, whose
  address names whichever host is serving — had nowhere to go but a host's own copy of
  `_values`, which meant copying the gem's loops. A copy drifts: one of them dropped the
  attachments and a record's image vanished from its page.

  A helper answers `{ label => value }` for a record instead, and the gem draws it as a
  cell on the table and a row on the record's page, a whole web address becoming the same
  link a cell of one would be. The fourth of the `recourse_extra_*` helpers, and the
  first to say what a record *is* rather than where to go.

  `_values.html.erb` leaves the list of partials a host may replace. A host wanting
  markup rather than a value still has `_row`.

* [Feature] A clone carries the records and files that belong to it

  Cloning copied a record's own columns and stopped there, which is not what a copy of
  anything with parts is. A model now names those parts, and they come along:

      class Provider < ApplicationRecord
        def self.recourse_cloned = %i[notions reviews departments photos]
      end

  Named there, an association is carried; unnamed, it stays behind. Nothing is guessed.
  `dependent: :destroy` looks like the signal and is not — it says what may not outlive
  the parent, where cloning asks what is part of it, and the two come apart constantly:
  a bookmark dies with the row it keeps and is still the reader's rather than the row's.

  One list, three behaviors, read off each association's own kind. A `has_many` or
  `has_one` is copied the same way, all the way down, so a model deep in a tree declares
  only its own children. A `has_and_belongs_to_many` is joined to the same records. An
  attachment is attached to the same file, so nothing is re-uploaded.

  At every level the copy is cleared of what no second row may inherit: the key, the two
  timestamps, every counter cache, and every unscoped-unique column. So a counter starts
  at zero rather than at the source's total, and a clone does not claim the age of what it
  copied. A position is cleared once, on the record the reader asked for, which lands
  last in its arranged table rather than on top of the row it was copied from; the copies
  under it keep the places they were in, the order somebody put them in being part of
  what was copied. `recourse_deep_clone` is the override for what a list cannot say.

  The copying moved to `create`, where there is a write to gather it for: the form sends
  columns and a record is not always one row, so the id it was opened with rides on the
  form's own action and the graph is built and saved there, in one transaction.

  The form says what is coming, since its fields are the record's own columns and
  everything else is carried out of sight: `Its audit, its seal, and 2 photos will be
  copied too.`

* [Feature] A record's own page clones it

  Making a near-duplicate meant opening the new form beside the record and retyping
  every value by eye. A `Clone` link now sits beside the breadcrumbs on a record's own
  page, wherever the resource draws a `new` form for it to open, and lands on that form
  with everything the record can lend already in place.

  `/places/5` leads to `/places/new?cloned_id=5`, which is the ordinary new form with a
  seed rather than a page of its own: the same title, the same trail, the same fields,
  and a submit landing on the same `create`. So a host that has overridden any part of
  its form gets that form here too, and no route, controller or template is added.

  A column validated unique with no scope opens empty — a copy of that value could never
  be saved. Read off the validators rather than the indexes, and a `uniqueness:` carrying
  a `scope:` is copied, since what makes that pair unique is the scope. Counters,
  positions, the id and the timestamps are outside what a form offers and were never in
  question; attachments and associations are not copied either.

* A show page reads what `recourse_displayed` names, as a table already did

  It read exactly what its form offered, so hiding a column to say nobody types it also
  took it off the record's own page — and a computed column is precisely one a reader
  wants and nobody writes. `/bands/:id` named neither the band nor its plan for that
  reason.

  `recourse_displayed` already meant "draw this anyway". It reaches both pages now, the
  timestamps still coming last. Nothing is offered for editing that was not before:
  `editable_columns` is untouched, so a form draws the same fields and permits the same
  parameters.

* No table draws a position

  A place in an order somebody set is what the order of the rows already says. Read at a
  level it is not counted at it says even less — the same figure down a column, once per
  parent — which is where a table used to draw one anyway. Both are dropped now: the
  column a model nominates, and the one a listing is arranged by, which is not always
  the same. `recourse_displayed` puts either back for a host that wants it.

* [Feature] A listing can be arranged by a column its model did not nominate

  `recourse_order` names one column as `:positionable` and refuses a second, because
  the order a table is read in and the order somebody put it in are one fact. A record
  can still sit in two orders at once: a plan holds a place among its service's plans
  and another among every plan of its department, which is reached through the service
  and by no key of the plan's own. The second listing drew no grips, since a table is
  arranged only where the rows a position is counted within are the rows on the page.

  A controller now answers `recourse_position` with the column its own listing is
  dragged by, defaulting to what the model nominates and to nothing where a position
  would mean nothing. The gem maintains only the model's own column, so filling and
  closing the gap in a second one stays the host's — as does telling the positions
  controller under that index the same two things, or a drop renumbers rows the page
  never showed.

* [Feature] A time zone is picked from a menu

  A column holding `Eastern Time (US & Canada)` is a string like any other to a
  database, and a box is the wrong thing to type one into: the values are a fixed list,
  spelled exactly, and there are a hundred and sixty-five of them. An attribute
  reporting `:time_zone` now draws the same searchable menu an enum does, built from
  `ActiveSupport::TimeZone` — Rails is what knows them, so a host says only that the
  column holds one, and an app whose own list is narrower says so in a validator.

  The type is your app's, the way `:monetary` and `:percentage` are: a
  `ActiveRecord::Type::String` whose `def type = :time_zone`. Two more answers narrow
  the menu, since most apps admit fewer than Rails knows and a menu of a hundred and
  sixty-five is a page rather than a control: `values` is what it offers, `common` what
  it opens on. The rest wait behind `All time zones`, the way a filter's unused options
  do, and the record's own zone is shown whichever list it is in.

  `All` reveals on either kind of menu and clears only on the kind that narrows a
  table: a menu that sets a value cannot mean none of them, and clicking the item
  already chosen is the plugin being told to choose it again — which shut the menu over
  the options the button was clicked to see.

* A refused bare action says why

  A write the model turns down re-renders the form with the errors beside the fields
  that earned them, which is the whole of what a rejection is for — where there is a
  form. A bare action has none: `recourses :sweeps, only: :create` routes no `new`, so
  `render :new` found the gem's own form template through the `recourses/` prefix and
  drew a page of fields for a resource that offers none, under a flash reading
  `Sweep could not be created.` and nothing about why.

  Such a write now goes back to the page its button stood on, saying what turned it
  down: the model's own `full_messages`, rather than the gem's sentence naming the
  model and not the reason. A validation on `:base` — a throttle, a guard against a
  double click — reaches a reader for the first time; the per-field rendering never
  drew one, having no field to draw it beside.

  Which makes a refusal worth writing where a button cannot be disabled. The gem draws
  a bare action's button and a host cannot dress it, so a model that refuses is how an
  app says not yet — and it holds against a second tab and two people clicking at once,
  which no disabled button does.

* A bare action lands somewhere

  A nested `recourses :sweeps, only: :create` drew its button, posted it, and wrote the
  record — then raised `No route matches {action: "show"}` on the way back. `create`
  came home to the index where one was routed and to the record's own page where none
  was, on the reading that a write with no index to return to is a singular resource's,
  and a singular resource is the collection of one. A plural nesting is the case that
  reading forgets: it routes no index to return to *and* no page of its own to land on,
  so both arms named a route nobody drew.

  It now goes back to the record it hangs off, which for a bare action is the page its
  button stood on — the only page it is ever drawn on. The record was written either
  way, so what this fixes is a 500 after a successful write, on every click.

  A host that answered such an action in a controller of its own never saw this, which
  is why the dummy app did not: it had one. That controller is gone, and the gem
  answers the action instead.

* A bare action can be answered at all

  `recourse :sweep, only: :create` draws a button, labels it from the path — the gem
  goes out of its way to name an action whose word this app has no class for — and then
  raised on the way in, because everything running before the action asked what model
  the page was about and a verb has none. Nothing in the dummy ever posted one, so the
  button had never been clicked in a test.

  What runs on every request now asks whether there is a model before reaching for one:
  the assign, the broadcast, and the two places the parent lookup asks a resource about
  its keys. The actions the gem serves still raise where the model is missing, which is
  a routes file to fix. A host's controller for such an action stays a
  `RecoursesController`, which matters — that is where a host keeps the filters guarding
  its admin.

* No bookmark or position route for a resource that can hold neither

  Both name one row by its id, and both were drawn for every top-level resource whether
  or not it had rows to name: `/weeks/:week_id/bookmark` for a page assembled out of
  other models' records, `/placeholders/:placeholder_id/bookmark` for a name with no
  model at all. Nothing linked to either, so they were dead rather than broken, and
  anything reaching one raised. They are no longer drawn.

* A write marks the row it landed on

  A successful create or update redirects to the index and says so in a toast: `Place
  was created.` The message names the model and never the record — interpolating one
  prints `#<Place:0x…>` — so a reader who has just saved the eleventh of twenty rows
  was told that it worked and left to find which one.

  For as long as that toast stands, the row now says so too: a tint across it in the
  success family, fading away over the second the message takes to go. Mixed into the
  page rather than taken from `--bs-success-bg-subtle`, which is a ramp step a palette
  builds by mixing toward white or black — the kept tint's own formula, one token
  swapped, so a row that is both kept and just written wears two tints that differ by
  hue rather than by shade. On the cells rather than the row, like
  the kept tint beside it — the table collapses its borders, so the cells are what
  paint, and one tint across all of them is what reads as a single row rather than as a
  box around each cell.

  One clock rather than two. The server names the row in a reserved flash key and the
  `written` controller lets go of it on Bootstrap's own `hide.bs.toast`, so holding the
  toast open by reading it holds the mark open too — `hide` and not `hidden`, which
  fires only once the toast has finished fading and would leave the row lit after it. That reserved key is kept out
  of the message loop on purpose: every other key in the flash becomes a toast of its
  own, whoever invented it, so an id left in there would have been announced as one.

  Doing it from the browser is also what keeps it clear of the table's fragment cache.
  A write expires that fragment, so the next render is the one that gets kept — and a
  highlight rendered into it would have been served to every later visitor until the
  write after that.

  The square that keeps a row leaves the same mark, through the same module: a
  bookmark is a write whose only report was a tint, which says which rows are kept
  rather than that this one just landed. With no toast to keep time with it runs the
  shared delay on a clock of its own.

  Every row gains a name of its own — `<tr id='place_4'>` — which is how a mark finds
  its row, and which a square already reached for by walking the DOM. A host's
  aggregate rows get none: they answer `to_key` with nil, and a name built from that
  is `new_week` twenty times over on one page.

* A heading over a foreign key says what the column is, not what a form would ask

  A key whose label is typed rather than picked took the field's own words wherever it
  appeared: `ZIP code` over the column, and — in a host with a table of addresses —
  `Location address line 1`. A box has to name what goes in it; a heading stands over
  what a record is called, and nothing is typed under one. So the table and the show
  page now say `ZIP` and `Location`, and only the field still says `ZIP code`.

* An aggregate can be drawn with the gem's own table, and such a table is never kept

  `Recourse::Aggregate` answered what a table asks about columns and keys, but not two
  questions asked a little wider: the column Rails reserves for single table
  inheritance, and the associations a bookmark or a counter is looked for along. Both
  are now answered as the nothing an aggregate has, so its page can render through the
  gem's table with a `_row` of the host's rather than a template written out by hand.

  And no such table is cached. A record says when it last changed and a fragment is
  filed under that; an object a host assembled in Ruby says nothing — `to_param` is nil
  for anything built on `ActiveModel::Model` — so a page of twenty of them was filed
  under a key that could not tell it from any other page of twenty, and the next reader
  of one was served the last reader's. Which no host had to notice: it looks like a
  page that will not refresh, on the reader's screen rather than in a test.

* A list of values reads behind the details an image already used

  A record's page draws a browser-renderable attachment as a `<details>`: the filename
  in the summary, the picture inside, closed to begin with, because a page is a column
  of values a reader scans and an image sitting open in one pushes the rest of them
  down. An array attribute wants exactly that, and until now got nothing: nothing kept
  one off a table, so a `text[]` fell through to the cell and printed the Ruby array's
  own inspect output, brackets and quotes and all.

  It now reads as `3 items` — or `1 item` — and opens to its values as a list. An empty
  one reads as the dash every other empty value reads as, rather than as a summary with
  nothing behind it. Both shapes come from one `detailed` helper, so a picture and a
  list are the same markup rather than the same markup written twice.

  A table counts one instead of drawing it — `3 items`, as plain text — since a column
  of values inside a column of values is not a table, and the values are a click away
  on the row's own page. The same words serve the cell and the summary, so the two
  never disagree about how many there are.

  A form takes a list one value to a line, in a textarea, and `ListResolution` splits
  the lines back into values on the way in — the same seam a typed reference is looked
  up at, so no host model needs a virtual attribute and no host needs a strong
  parameter of its own. A newline is the one separator a value cannot itself contain,
  where a comma can sit inside a tag, and a blank line is somebody pressing return
  rather than a value they meant to keep.

  Which columns those are is a type that wraps a subtype, which is what a PostgreSQL
  array reports and what a `serialize` of an Array reports too — the same question the
  search box already asked to pass a list over, asked the same way, since an adapter's
  own class only exists where that adapter is loaded. An enum answers that question the
  same way and is not a list: Rails wraps the column's own type to map the words onto
  it. Asking `defined_enums` first is what keeps a status a word rather than a list, on
  the table and on the form both.

  The dummy carries `Place#tags` for this to be covered by. SQLite has no array column
  — `array: true` is a PostgreSQL-only option and every other adapter raises on it — so
  it is a `text` column with `serialize`, which reports the same wrapped type the real
  thing does. CLAUDE.md's rule is split rather than dropped: our own apps still model a
  list as a table of its own, and the gem reads one a host already has.

* [Feature] A page a host assembles out of its own records can be an index

  `Recourse::Aggregate` describes a resource with no rows of its own — the weeks memos
  were written in, the periods a subscription was billed for — and answered every
  question the gem asks a model. It could not be listed: the index put its collection
  through `Search`, which asks a relation for its class and for a ransack query, and an
  Array of anything answers neither. A host wanting such a page had to override `index`
  outright and give up the paging with it.

  A collection that is no relation now passes through untouched — no box above it, no
  sortable heading, nothing eager-loaded, which is what `Aggregate` already said it had
  none of — and is paged like any other index. The rows are the host's own template,
  since there are no columns to lay a table out from; everything around them is the
  gem's.

  The two generators pass such a resource over rather than asking a class with no table
  what its keys are, and say so as they go.

* A typed foreign key naming more than one row is refused rather than guessed at

  A label offered to be typed is short enough to say, which is not the same as saying
  which row it means — and nothing in the schema promises it does. Where two rows
  answered to the same words the first of them was written, and the page said it had
  worked: a key pointing somewhere nobody asked for, quietly, and in a host's data
  something belonging to one owner reassigned to another's.

  Such a write is refused now, and the field that asked says what the words matched.
  Nothing else moves: a label naming one row resolves as before, and one naming none
  leaves the key empty for `belongs_to` to answer for.

* [Feature] A month reads as its name, and a year is not a quantity

  Two kinds a `decimal` and an `integer` could not tell apart on their own. A `:month`
  is drawn as the word for one — `August`, not `8` — and a `:year` as the digits it is,
  since a year counts nothing and `2,025` is never what anybody meant. Both take the
  whole-number step an integer does, where a kind the gem had not heard of would fall
  through to a text box that admits `2025.5`.

  Types your app registers, like `:monetary` beside them: what a month may *be* is the
  app's to say, a type being unable to validate. The dummy's `Place` gains one of each,
  told apart from the counts beside them by the type each attribute reports rather than
  by the name of the column.

* A page is read against the reader's own clock

  Every time the gem printed was drawn in `config.time_zone`, so a reader in
  California read `Jun 1 at 09:30am EDT` and did the arithmetic themselves.

  The browser now reports its zone into a cookie, and the server renders in it: the
  same row reads `Jun 1 at 06:30am PDT` in California and `Jun 1 at 10:30pm JST` in
  Tokyo. Moving the zone rather than the text is what makes this worth having — the
  edit form is drawn in the same zone as the page beside it and reads a typed value
  back in it, so the record keeps the instant it would have kept anywhere else.
  Localizing in the browser would have left the form behind, saying `9:30 AM PDT` on
  one page and `12:30 PM` on the next.

  A date is untouched, in every zone. It is a day rather than a moment and has no
  hour to shift; the browser-side version of this would have read `Jan 1` as `Dec 31`
  for everybody west of Greenwich.

  Nothing of the host's is written. `Time.use_zone` restores the old zone in an
  `ensure` and `Time.zone` is per-thread state rather than config, so a host's own
  screens are drawn against its setting as before. A cookie naming no zone anyone
  knows is nil, which falls back to that setting too. Storage stays UTC throughout.

  A table's cache key gains the zone, for the reason it already carries the viewer's
  bookmarks: without it the first reader to load one would settle what hour everybody
  else read.

* A timestamp says how far off it is

  Hovering a datetime now reads `3 minutes ago`, or `in 9 years`. The server
  writes those words with Rails' own helper, which is what a reader without
  JavaScript gets, and the browser says them again on the way to the tooltip — a
  table is cached and a page is left open, so words rendered on the server are only
  true at the moment they are drawn.

  Only a datetime. A date is a day and a time is a time of day, and neither is a
  moment for a distance to count against.

* A reader says how much of a table one page shows

  Every index paginated at twenty rows and nobody could say otherwise. `?limit=` in
  the address bar was ignored on purpose — pagy's `max_limit` is unset, so a stranger
  cannot ask a host for a page of 100,000 rows — but that closed the door on the
  reader as well as on the stranger. Scanning 101 ZIPs meant six pages of twenty.

  There is now a switch after `Displaying items 1-20 of 101 in total`, past a dot,
  reading `100 per page`. Clicking it makes that the size, and it then reads
  `20 per page` — it always names where a click goes, since the sentence beside it
  already says where the reader is. The choice is kept in a cookie of the reader's
  own and used by every index in the app from then on: no parameter in any address,
  nothing written to the host's database, and `max_limit` still unset. The cookie is
  checked against the two sizes we offer on the way in, since a cookie is a value a
  stranger can write too.

  The switch appears only while there is a second page to reach, alongside the page
  links it belongs with. Clicking it goes back to the first page: page five of
  twenty is past the end of a hundred to a page.

* A counter cell keeps its tooltip for the width that needs one

  A cell counting what a row holds reads `3` where the table is narrow and `3 places`
  where it is wide, and it offered `Places` under the cursor in both — repeating, on
  the wide table, the word already printed in the cell.

  The tooltip now rides on the bare figure rather than on the link around it. The
  stylesheet hides that figure at `xl` in favour of the phrase, and an element that
  is `display: none` is one nobody can hover, so the tooltip goes quiet exactly where
  it had nothing left to add — the same mechanism the icon heading above it already
  used. The cell writes the count out twice to make this possible, once bare and once
  with its word, each a whole thing to show or hide.

* The navbar and the sidebar hold still while a long page scrolls

  A table of any length took the whole page down with it: the breadcrumb, the buttons,
  the search box and every sidebar link left the screen at the twentieth row, and
  getting back to any of them meant scrolling back to the top first. On the one page
  a reader spends their time on, the two things they navigate by were the two things
  hardest to reach.

  Above the width the sidebar becomes a column at, the shell is now exactly the window
  and `main` is the only thing in it that scrolls. The navbar and the sidebar stay
  where they are. Below that width nothing changes: the sidebar is a band across the
  top and the page scrolls as one, which is the only thing that reads on a phone.

  The scheme toggle at the foot of the sidebar keeps its `sticky`, which now holds it
  against the foot of a sidebar that scrolls itself rather than against the foot of
  the page.

  Every rule here names the row it is about by the path down to it rather than as any
  `.row` inside the shell. A show page lays its values out in one of those and a form
  lays its fields out in another, and stopping *those* from wrapping puts three
  half-width values on one line where there should be two rows of two.

* [BREAKING CHANGE] A link reads as its host rather than as the whole address

  A value that is one web address has always been a link to itself, and what it said
  was the address — every character of it. That is fine for `https://acme.com` and
  useless for a log URL carrying a fifty-character identifier: the column widens to the
  longest row in the table, and what a reader gains over the row above is nothing, the
  part that differs being the part they cannot read anyway.

  So a link now says the host and stops: no protocol, no leading `www.`, no trailing
  slash where the address ends at the host, and `/…` where a path follows. The href is
  untouched, which is what a click needs, and the whole address is a hover away.
  `https://www.google.com` and `https://google.com/` both read `google.com`;
  `https://platform.openai.com/logs/conv_698c…` reads `platform.openai.com/…`.

  `WEB_URL` now captures the two parts it decides between, and requires a host to match
  at all — `https:///path` is no longer a link, having none.

  Breaking because every link on every page reads differently. A host that wanted the
  address on the page still has it in the `href`, and a table that must print it is a
  `_row` partial away.

* [BREAKING CHANGE] The kind a currency is drawn by is `:monetary`, not `:price`

  A type reporting `:price` is no longer read as money — `NUMERIC_KINDS`, the value
  formatter and the adorned field all say `:monetary` now. A host whose type answers
  `def type = :price` loses its currency and its adornment, and reads as the decimal it
  is stored as; changing that one line is the whole migration, and what the class is
  called and registered under stays the host's own business.

  `:monetary` rather than the obvious `:money`, which is a native type on PostgreSQL:
  Rails raises `TypeConflictError` rather than let an app shadow an adapter's own, and
  `override: true` would be the price of a word worth nothing to own. The dummy runs on
  SQLite and would never have met that.

* A menu no longer insists the table behind it keeps timestamps

  The rows behind a combobox are cached on the relation they were read from, and Rails
  keys a relation on `MAX(updated_at)` without asking whether the column is there. A
  form offering a menu over a table with no timestamps answered `PG::UndefinedColumn`
  rather than a menu — and reference data is exactly where an app keeps none, a table
  of states or of postal codes being written by a migration and read forever after.

  Such a menu is drawn each time now instead of kept, there being nothing to version it
  by. Everything else is unchanged: a table with timestamps caches as it did, and an
  index was never affected — what it hands the view is a page of records rather than a
  relation, so its key is built from the rows themselves.

* [Feature] A table that says it is arranged is kept numbered

  A model whose `recourse_order` marks a column `:positionable` had two things left to
  do that the gem never said out loud, and its own screens did not work without them.
  The form it draws never asks for a position — a reader sets one by dragging a row —
  so a column the schema insists on was filled by nothing, and the first Add answered
  `NotNullViolation`. And the delete button it draws left a hole, after which every drop
  landed beside where it was aimed: what a drag reports is a row's place on the page,
  which means a position only while the table runs 1, 2, 3 with no gaps.

  Both come with the word, and nothing is included to get them: the order a table is
  read in and the order somebody put it in are one fact, so a model that says
  `:positionable` has said this too. A new row lands last among its own, the gap closes
  behind one that goes, and the rows either is counted among are worked out from the
  model: what it points at, or the whole table where it points nowhere. Where more than
  one key could be the parent — a picture belongs to a department and to the file it
  shows — the model says which by answering `recourse_siblings`, and is told to rather
  than guessed at.

  The callbacks sit on every model and read `recourse_order` when they fire, doing
  nothing where no key there says `:positionable` — the same reach `Recoursive` already
  makes, and the reason a host writes nothing at all.

  Moving a row was already the gem's, and stays there. Writing the new position on the
  record itself is not: a host whose own pages do that keeps whatever closes up behind
  it, since two things shifting the same neighbours leave two rows on one number.

  `Recourse::Positioning` now takes the relation and the column, and answers `move` and
  `close` rather than `move_to`. Internal, and named nowhere in this README.

* [Feature] A nested route may name a parent through a polymorphic key

  The parent a nesting names was found by matching a `belongs_to`'s own name against
  the path, which a polymorphic key can never answer to: it names no one table, so the
  segment above it is the concrete parent's own — `/posts/2/comments`, never
  `/abouts/2/comments`. Such a nesting resolved no parent at all, which left its index
  listing every row in the table, its form asking for a raw `*_id`, and `create`
  writing a record that belonged to nothing.

  What settles it now is the parent's own half of the association: `has_many :comments,
  as: :about` on the post says both that this nesting is that association and which of
  the model's keys it is, where it keeps more than one. The page then reads like any
  other nested one — its rows are the parent's, the key stays off the table and off the
  form, and the write puts the class name beside the id, since a key carrying one
  without the other points into every table at once.

  The rows a drag counts among are that parent's too. The route that arranges a listing
  is drawn a segment below it, where no nesting is recorded, so the parent is looked up
  from the listing's path rather than the controller's own — otherwise a page correct to
  read would renumber every other parent's rows on a drop.

  A parent declaring no such `has_many` resolves no parent, exactly as before: a page
  gathered from several parents at once is nobody's one record, and `recourse_relation`
  is still what scopes it.

* [BREAKING CHANGE] A row reads in the order its columns' kinds earn

  Which column came first was whichever came first in the table, which is a fact about
  the migration that created it and about nothing else — and PostgreSQL cannot move a
  column, so an app wanting its tables to read well rebuilt them. Fountain carries 25
  migrations that do exactly that, and a column added afterwards still lands at the end
  of the row where no rebuild can reach it.

  A column's kind now decides which part of the row it reads in: the counts, then what
  kind of row it is and what state it is in, its flags, whose it is, what it says, the
  long values, when it happened, and last the two timestamps. Inside one of those the
  order is the table's own, so an order already in the schema stands, and a column added
  later joins its own kind instead of the end of the row.

  The show page and the form read the same order as the table for the first time, which
  is what they have always claimed to do.

  Breaking because every table, show page and form reorders. A host that had arranged
  its columns by migration will find most of that arrangement kept and some of it
  overruled, with no way to say which — a table that needs an order of its own still
  writes a `_row` partial.

* A button that performs no longer wears a link's dress

  `.btn-outline` is reserved for the navbar's `Add <resource>` link, and STYLE.md says
  so three times over — a button dressed as a link promises a navigation where there is
  an action. Two `button_to`s wore it anyway: every bare action beside the breadcrumb,
  `recourse_extra_actions` among them, and the Add/Remove writing a join beside each row
  of a listing. Both are `.btn-solid` now, the first keeping `theme-primary` and reading
  as the filled button the index's bare `Create` already was, the second staying neutral
  so a column of them does not shout over the rows it is about.

* [BREAKING CHANGE] A bare action's button stands on one page, not on every page

  The button for an action the routes drew under a record sat beside the breadcrumbs on
  whichever of that record's pages was open, which put `Add HouseCanary` and `Add
  Realtor` side by side on a location's own page and on each other's. The rule the gem
  already stated for tabs now governs buttons too: a nesting with a page of its own
  draws its button there and nowhere else, and one with no page anywhere — `recourse
  :sweep, only: :create` — draws it on the record's own show page, since every other
  page of the record is about something else.

  A singular resource routed both `create` and `destroy` also stops offering the wrong
  one. The record decides: `Add seal` while the `has_one` holds nothing, `Delete seal`
  once it does. Before, whichever of the two came first in the routes won, so a
  singular routed both always read `Add`.

  Breaking for a host whose tests look for a button on a page that no longer carries
  it, and for one relying on an action being reachable from a record's every page.

* [Feature] The gem finds a singular resource's record

  A singular `recourse` is reached with no id, and finding the one record it stands for
  was the host's job — every app wrote the same `def find_resource = assign
  @recourse_parent.property`. The gem reads it off the parent now, under the name the
  route already gives it, whether the parent keeps it with a `has_one` or points at it
  with a `belongs_to`. Where the parent has no association of that name the record is
  still the host's to find, which is what leaves a page reached through something else
  — a chat a nomination gets through its booking — to a controller of its own.

  Where the association holds nothing, a resource routed `new` redirects to the form
  that makes one; one without still says `No property.` on the page. And a write on a
  singular resource lands on the record's own page rather than raising for an index the
  routes never drew.

* A JSON value reads as JSON

  A `json` or `jsonb` column on a record's page was printed as the Hash Ruby prints,
  one line as wide as the payload. It is `JSON.pretty_generate` in a block of its own
  now — indented, wrapped, and bounded to a height it scrolls within — so a service's
  answer is readable and nothing else on the page moves aside for it. An empty payload
  reads as the dash, not as `{}`.

* [Feature] A resource may name its own model, and may keep no rows at all

  Two things a host had to fake before. A screen whose route is not named after a
  model — `neighbors`, listing what a measurement answers rather than what a table
  holds — needed a class of that name to exist, so a host wrote an empty subclass for
  the gem to find. `def recourse_model = Location`, private beside `recourse_relation`,
  says it instead: what a page is called and what it lists are two separate things, and
  the local a row partial receives is still named after the route.

  And a resource that keeps no rows at all — a page assembled out of other models'
  records — had to answer eight questions a table answers from its columns and its
  associations, one method at a time, because the defaults reach for
  `reflect_on_all_associations` and a class with no table has none.
  `include Recourse::Aggregate` answers them all as the nothing an aggregate has, and
  brings the naming a title reads a word from, so such a class says only what it is
  called and drawn with.

* A search box no longer names a label Ransack will refuse

  A foreign key whose model is too long to list is searched through rather than
  filtered by, under the far model's label — `location_street` for the ZIP a booking
  is at. Whether that label could be searched at all was asked of its type, and
  encryption leaves a type alone: an encrypted `street` reads as a word here, so the
  box asked for `specialty_name_or_location_street_or_provider_name_cont` and Ransack
  answered with a `NoMethodError`. Every index reaching that model through a key
  raised — five of them, in the app this was found in — and only in an environment
  with enough rows to stop the key being a menu, so a test suite drew a filter where
  a browser drew a term and never saw it.

  The label has to be a column Ransack will answer to as well, which is the allowlist
  rather than the type. A model whose label the search cannot match is no longer
  reached through: its key stays a filter where it can be one, and the box looks
  through what is left.

  A host relying on the old behaviour was relying on a 500. One whose label is
  encrypted loses the ability to search through that key — name a plaintext column as
  the label to get it back.

* A singular nested `recourse` routed `show` earns a tab, not nothing

  `recourse :property` under a location is one record reached with no id of its own,
  and Rails' `resource` draws no index for it — so a nesting the gem only drew a tab
  for where an index was routed could never earn one. `recourse :lead, only: :show`
  was routed, served, and linked from nowhere at all; `only: %i[new create show]` was
  the same, the `new` route being enough to suppress the button a bare action would
  otherwise have earned.

  A nesting with no index and a `show` the router needs no id for now earns a tab on
  the record it hangs off — beside Show and Edit, in the order routes.rb nested it,
  pointing at `/locations/5/property`. It reads in the singular, since there is only
  ever one: `Property`, or `HouseCanary` where a locale renamed the model. That word
  comes from the same split and the same `Recourse.known_singular` the bare action's
  button takes it from, so a tab and a button under one record cannot come to
  disagree. No count, since a `has_one` has nothing to count, and no icon, since an
  icon on a tab comes from an association the gem counted and from nowhere else. An
  index still wins where a host drew both.

  The crumb naming such a page reads the same way, and used to read the plural. Rails
  routes a singular resource to a plural controller, so the path says `properties` for
  the one property a location keeps, and the trail over it said `HouseCanaries` for a
  page there is only ever one of.

  And the page says so where the host found nothing. A singular resource is reached
  with no id, so the one record it stands for is one a parent may not have yet — an
  optional key, a `has_one` nobody has written. Such a page reads `No property.`, the
  singular of what an empty index says, rather than reading attributes off nothing.

  A page nested under a record now sits in that record's card whichever page it is.
  `show` and `edit` were handing the card their own record while the tabs above it
  were built from the parent's path, so a nested `/posts/1/ratings/2` drew a Show tab
  pointing at `/posts/2`. Nothing linked to such a page before, which is why nobody
  saw it; a singular resource's tab is the first thing that does.

  Any host with a singular nested `recourse` routing `show` will see a new tab on
  every one of that parent's records — the ones whose `has_one` is nil included. A
  singular resource has no id to look up, so what the page reads out was always the
  host's to find, and now something links to the page it finds nothing for. The chrome
  holds: a record the host did not assign leaves the crumb above it unnamed rather
  than raising, where `resource_record_label` used to read `attributes` off the nil.
  What the body says about the absence is the host's to write — or the host redirects,
  the way one asking a service for an answer it has not fetched yet already does.

* A JSON column stays off an index table

  A `json` or `jsonb` column used to reach a table, where the gem has no arm for one —
  so the Hash was stringified into a cell and one payload made the row wider than the
  page. It now joins what a table leaves off by default, beside ciphertext, the
  primary key and the timestamps: a payload is a service's answer kept whole, not
  something the row is about. `def recourse_displayed = :property_details` puts it
  back for a host that wants it, and the record's own page reads it out either way.

  Search and sorting are unaffected — `json` was never a searchable type.

* A bare action's button is named for the route it is, namespace and all

  A nested resource routed `create` with no `index` gets a button on its parent's
  card, and that button took its word from the last segment of the path — so
  `namespace(:quick) { recourses :memos, only: :create }` under a person read
  `Add memo`, exactly like the `memos` index beside it, and the two posted different
  records to different controllers. It now reads `Add quick memo`. The namespace is
  the only thing telling two routes to the same model apart, and the tab for a
  nested index already read that way; both now come from one split.

  Any host with a namespaced bare action will see its button's wording change.

* A counter's cells say what they count, without drawing anything

  A counter cache's heading names the counted model and its cells hold the bare
  figure, which stops helping the moment the heading scrolls off the top — and a
  link whose whole text is `38,405` announces as `38,405` and nothing else. Each
  cell now carries a tooltip reading the model's plural and an `aria-label` reading
  `38,405 ZIPs`. An unlinked count is a `<span>` carrying the same pair, so it is
  named like a linked one.

* The scheme toggle holds the foot of the viewport

  At the foot of a sidebar as tall as the table it sat below the fold on any long
  index, which is where it is least use. It is now `position: sticky`, so it holds the
  bottom of the window while the content beside it scrolls and comes to rest in its
  real place at the end — sticky rather than fixed, so it keeps the sidebar's column
  and can never land over the table.

* `:bootstrap` joins `Recourse::THEMES`, so the toggle can rotate back to it

  Bootstrap's own palette was reachable only by not setting one, which meant a reader
  who clicked the sidebar's toggle could never get the pages' original look back. It is
  now a palette like the other eight, whose stylesheet declares nothing: the eight work
  by overriding upstream's `:root`, so dropping their block is all it takes. The default
  is still nil, so a host that names no palette still links no stylesheet at all.

  `THEMES` is now a name mapped straight to its dark-label families rather than to a
  hash. The `primary:` key it used to carry had no reader left after each palette began
  declaring its own `--bs-primary-*`, and dead data that can drift from the stylesheet
  is worse than none.

* A kept row is tinted, and the tint is what reports the click

  A table whose model keeps bookmarks now paints the whole `<tr>` of a row the viewer
  has kept — a twelfth of the primary mixed into the page, so it follows every palette
  and both color modes. Twenty rows are scanned by it long before anybody reads a
  column of icons. It is a background rather than Bootstrap's `.table-active`, which
  sets the same variable `.table-hover` does and would leave a kept row looking like
  the row under the cursor.

  The square's success toast is gone with it. The icon still flips on the click, but
  the row takes color only when the write comes back, so the confirmation lands where
  the click happened instead of in a corner of the page — and a column built to be
  clicked twenty times no longer answers with twenty toasts. Only a failure speaks
  now. The no-JavaScript path still flashes `Bookmark added` and `Bookmark removed`,
  since it reloads the page and would otherwise say nothing.

  `data-bookmark-messages-value` is now `data-bookmark-error-value`, a string rather
  than JSON, which matters to a host that had overridden the square.

* [BREAKING CHANGE] `recourse_timestamps` is gone; `recourse_displayed` asks

  A model that showed `created_at` or `updated_at` on its table said
  `def recourse_timestamps = %i[created_at updated_at]`. It now says
  `def recourse_displayed = %i[created_at updated_at]`, which is the hook that
  already named back every other column a table leaves off — the encrypted ones, the
  primary key, a polymorphic `*_type`, the inheritance column. Two hooks meaning
  "draw this anyway" were one too many, and unlike the old one this accepts a single
  symbol as readily as a list.

  The timestamps still come last, and still `created_at` before `updated_at` whatever
  order they are named in. Nothing else moves: the show page reads both out for every
  model as before, forms still never offer them, and every heading a table shows can
  still be sorted by.

* `Recourse.theme` draws every page in a code-editor color scheme

  Eight of them — `dawn`, `dracula`, `gruvbox`, `monokai`, `nord`, `one_dark`,
  `solarized` and `tokyo_night` — set from an initializer with one line. Bootstrap
  derives every surface, border and text color from one neutral ramp and names each
  of its meanings after a family, so repainting the ramps carries a scheme to the page
  itself rather than only to its accents. Each is a stylesheet the engine serves at
  `/recourse/themes/<name>.css`, and each fills both arms of every ramp, so a page
  still follows the reader's system setting. `Recourse.color` composes with it: the
  scheme repaints the ramps, the color says which repainted ramp is primary.

* The sidebar ends with a moon or a sun, and a reader picks their own palette

  A click moves the page to another of the eight and into the other mode — a moon
  while it is light, a sun while it is dark — so the schemes are reachable from the
  page rather than only from an initializer. The next palette is random among those
  not showing. The choice is kept in the reader's browser under
  `localStorage['recourse-scheme']` and put back before the first paint by an inline
  script in the head, and again by the controller on `connect`, since Turbo merges the
  head on a visit. The mode is forced with Bootstrap's own `data-bs-theme`, so until a
  reader clicks the page still follows their system setting.

  Each palette now declares the nine `--bs-primary-*` itself, from the family it leads
  with, so the primary travels when the stylesheet is swapped. `Recourse.color` still
  wins where a host names one. `Recourse.primary_color`, added earlier in this release,
  is gone with it — the palette answers that now.

* `--bs-primary-contrast` follows the family instead of always being white

  The label on a solid button is now `var(--bs-white)` or `var(--bs-gray-975)`,
  whichever reads better on the step the button is filled with — upstream's own shape,
  since Bootstrap gives `warning` and `info` a dark label for the same reason. This
  fixes `Recourse.color = :orange`, where white on `orange-500` was 2.90:1, under the
  3:1 WCAG asks of a UI component. `blue`, `brown` and `gray` gain a dark label too.
  `_color.html.erb` takes the ink as a second local, so a host overriding that partial
  should expect it.

## 4.0.0 - 2026-08-15

Version 4 is a rewrite, developed under the working name `drive` and released here
because it is the same library: the module is still `Recourse` and the entry point is
still one word in `config/routes.rb`.

Version 3 drew the routes and served one screen — a paginated, searchable index — and
left the controller, the other six actions and every form to the host app. Version 4
serves all seven, defines the controllers itself, and works out what each screen should
look like by reading the model: its validators, its associations, its column types and
its indexes. Most of what a host used to override is now something it no longer writes.

* [BREAKING CHANGE] Rails 8.1 and Ruby 3.2 are the minimum
* [BREAKING CHANGE] `recourses` defines the controller as well as the routes

  A host no longer writes `class PostsController < RecoursesController` for each
  resource. The controller is defined as the route is drawn, and a host that wants one
  of its own still writes it — the gem only fills the gap. `RecoursesController`
  changes meaning with that: it is no longer the class each resource subclasses but the
  one they all inherit, and a host defines it — `class RecoursesController <
  Recourse::BaseController` — to put a `before_action` above every screen at once.

* [BREAKING CHANGE] `search_field` and `search_prompt` are no longer yours to define

  They are derived now, and written down in the README so you can see what a page will
  do rather than so a model can answer differently. A search box looks through every
  indexed string column the table shows, plus the label behind a foreign key too long
  to list, and says so in its own placeholder. `searchable_fields` is gone outright.

* [BREAKING CHANGE] The Ransack hooks default to something instead of to nothing

  `ransackable_attributes`, `ransackable_associations`, `ransortable_attributes` and
  `filter_fields` are still yours to override, but a model that says nothing is now
  fully searchable, sortable and filterable rather than not at all: a column is
  sortable when an index covers it — the only signal a schema gives about which
  columns identify a row rather than describe it — an enum earns a filter, and so
  does each `belongs_to`. A host that listed columns by hand can delete those methods.

* [BREAKING CHANGE] A `filter_fields` entry changed shape

  It is keyed by the predicate and carries its options:
  `{ 'state_id_in' => { label: 'Home state' } }`.

* [BREAKING CHANGE] `recourse_searchable?`, `recourse_sortable?` and `recourse_cachable?`
  are gone

  The first two follow from the indexes. Caching is no longer a per-model switch: the
  table is a fragment keyed on the relation, so it expires when a row changes and needs
  nobody to remember to turn it off.

* [BREAKING CHANGE] `Recourse.resources` and `navigation_links` are gone

  The gem draws its own sidebar from the resources `recourses` declared, so a host no
  longer builds a navbar out of that hash. `NavigableHelper` and its
  `NAVIGATION_ICONS` table went with it: an icon now comes from the `unicon` gem,
  named by `recourse_icon`, which defaults to the model's own name.

* [BREAKING CHANGE] `search_highlight` takes the column, not the model

  `search_highlight(post.content, model: Post)` becomes
  `search_highlight(post.content, :content)`. Only a column the search actually looked
  through is marked, so a highlight can no longer claim a match that never happened.

* [BREAKING CHANGE] A row partial sorts with `sort_header`, not Ransack's `sort_link`
* [BREAKING CHANGE] Pagy 43 and Ransack 4.4 are the minimum
* [Feature] Every action is served: index, show, new, create, edit, update and destroy
* [Feature] A form field is chosen to suit each column, and carries the rules the
  model's validators state — a length becomes a `maxlength`, a format becomes a
  `pattern`, a numericality becomes a numeric keyboard
* [Feature] An enum becomes a badge on a page and a menu in a form; a foreign key
  becomes a menu of the records it points at, or a field to type into where there are
  too many to list
* [Feature] Values are formatted by what the column holds: delimited integers, decimals
  at their own scale, phone numbers, times in a `time` tag, links for a URL
* [Feature] Nested resources are drawn as tabs on the parent's card, counted where a
  counter cache exists
* [Feature] Active Record Encryption is respected throughout: an encrypted column never
  reaches a table, arrives masked on a record's own page behind a `Show`, and is offered
  in the clear on the form that edits it
* [Feature] Turbo drives the screens — frames, morph refreshes, and a delete that names
  what is about to go with it before it goes
* [Feature] Bootstrap 6 and Bootstrap Icons are vendored and served by the engine, so a
  host with no asset pipeline and no CDN still gets styled screens
* [Feature] Three generators: `rails g recourse` writes a model, its migration, its
  route and its seeds; `rails g recourse:counters` writes both sides of an association;
  `rails g recourse:seed` writes varied rows for every resource drawn
* [Feature] `Recourse.color = :purple` restyles every screen at once
* [Feature] Model hooks for the rest: `recourse_label`, `recourse_hidden`,
  `recourse_timestamps`, `recourse_order`, `recourse_icon`, `recourse_includes` and
  `recourse_broadcasts?`
* [Feature] Every string the gem shows is a key in `config/locales/recourse.en.yml`

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


