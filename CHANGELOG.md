# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## [Unreleased]

## 7.6.0 - 2026-09-20

* [CHANGE] The layout titles the page, so a host template cannot lose it

  The four templates each set `content_for :title`, so a host writing one of its own —
  which is the whole point of the gem drawing the rest — left the tab reading `Recourse`.
  The title is chrome like the trail beside it, and the layout works it out from the same
  place: what the trail ends with, the resource it is of where the record names nothing,
  and the app's own name where neither answers. `content_for :title` still wins where a
  host sets one.

## 7.5.0 - 2026-09-20

* [FEATURE] A model may word its own deletion

  Deleting is not what every model does when a row goes: an account is disconnected, a
  note is withdrawn. Both the button and the heading over the dialog now read
  `recourse.models.<model>.delete` and `recourse.models.<model>.deletion_title` where a
  host wrote them, and the one word the gem has where nobody did. Keyed off the record's
  own class, so a subclass words it apart from its siblings — and a slash in an i18n key
  is a nesting, so `integration/jobber` sits under `integration` in the locale.

## 7.4.0 - 2026-09-20

* [CHANGE] A singular resource that has its record reads it rather than offering a form

  `new` drew a form for a second record where the parent already kept one. At most one is
  what singular means, so the reader is sent to the page that reads it — the mirror of the
  redirect that already sent them to `new` when there was none yet. Before the action
  rather than inside it, so a host writing its own `new` gets it too.

* [FIX] Every file in the gem is under a hundred lines again

  Seven of them had grown past it. Each split along a seam it already had: web addresses
  out of `Formats`, the trail out of `Navigation`, the counter lookups into `Counters`,
  what a form sent into `ParameterResolution`, and which columns a screen uses apart from
  what order they read in.

## 7.3.0 - 2026-09-20

* [CHANGE] A boolean reads as the word a reader answers with

  A cell and a value read `true` and `false`, which is what the database keeps and not
  what anybody asked. Both now read `Yes` and `No` — the two the filter menu beside the
  column already offered — and a nullable column nobody answered reads as the dash every
  other empty value reads as, rather than as a no.

## 7.2.1 - 2026-09-20

* [FIX] A refused change keeps the card it was made in

  The card is drawn around a record's own pages, worked out from the action: `show` and
  `edit`. A write a validation turns down draws `edit` again under the name `update`, so
  the tabs went with it and the reader was left with a form and no way back.

## 7.2.0 - 2026-09-20

* [CHANGE] A row a model will not give up says so, rather than raising

  `destroy` was `destroy!`, so a `before_destroy` that threw `:abort` answered a reader
  with a 500. The page keeps the row and says `Specialty could not be deleted.`, the way
  an update that a validation turned down says what it says.

## 7.1.0 - 2026-09-20

* [CHANGE] The card draws the button that deletes what the page is about

  It was drawn by the gem's own `edit` template, so a host writing a template of its own
  lost it and wrote `destroy_resource_button` back by hand. The card draws it now, the way
  it draws the tabs and the buttons beside the trail, and a host's page is its body alone.

  A record's own page carries it, whichever of the two is open, so a resource routed to be
  read and deleted but never changed is deleted from the page that reads it. Nothing gains
  the ability to delete what it could not: a route without `destroy` draws no button.

* [CHANGE] A column the database generates is never offered on a form

  Postgres writes a stored generated column out of the others and takes no value for one,
  so a field for it would be refused whatever was typed. Such a column is read on every
  other screen as before.

## 7.0.0 - 2026-09-19

* [BREAKING] What a page counts is the gem's to work out

  `recourse_counters` is gone from every model. A column is counted where it holds a
  counter cache, as before, and now also where it is named `<association>_count` for an
  association the model has -- so a figure the app keeps itself, a `has_many through`
  Rails will not cache among them, is drawn as a count without being declared.

  The rule a host signs up for: a `*_count` column whose prefix names an association must
  hold the count of that association. One naming nothing is an ordinary number, and one
  naming an association it does not count wants another name -- the heading and the link
  a counter draws would both say the wrong thing. `recourse_hidden` takes such a column
  off the screens.

* [BREAKING] A record's card is the layout's, not the template's

  A host writing its own `show`, `edit` or nested `index` for a recoursed model used to
  replace the whole page, card and all, and wrote `render layout: 'recourses/card'` back by
  hand to get the tabs and the buttons beside the trail. The card is drawn around whatever
  template answers now, so a host's page is its body and nothing else.

  Every host view still wrapping itself draws a card inside a card: drop the wrapper. A page
  that wants the width to itself assigns `@recourse_card = false`.

  `card_record` is what the card is about -- the parent on a page nested under one, the
  record itself on its look and its change -- which is the rule every hand-written wrapper
  was already passing.

## 6.0.0 - 2026-09-19

* [Change] These pages are drawn from bh

  They were drawn from a package named after one company's design system, pinned by hand in
  `Recourse::BUNDLE` and fetched from a CDN. They are drawn from `bh` now, which is the
  Bootstrap layer under that package and is a dependency of this gem, so the version in the
  lock file is the version on the page and nothing is fetched across a network.

  `Recourse::BUNDLE` is gone. `Recourse.assets` stays, defaulting to bh's own engine, for a
  host serving those three folders from somewhere else.

  The host's `recourses/head` partial is drawn last in the head rather than before the
  script, so a stylesheet of the host's outranks the rules above it and a module of its own
  runs after the application this one starts.

* [Change] The flash is bh's toasts

  `recourses/_flash` and `FLASH_THEMES` are gone: the markup was bh's, written twice. What
  is this gem's own stays — the row a write landed on, and the link spliced into the words
  a message says — and rides on `toasts` through its `data:` and its block.

* [Feature] Every tab wears its model's icon

  A tab earned one only where the parent kept a `has_many` of that name, so a nested index
  reached through a join, and every singular resource, read as words alone beside tabs that
  had pictures. The icon is now looked up from the route, which is the same question the
  sidebar and the crumbs already ask.


## 5.6.2 - 2026-09-18

* [Fix] A kept table notices a count that changed

  The key a table is cached under carried the rows, the newest `updated_at` among them and
  everything they reach along `includes` — but not the counts they draw. A counter cache is
  written by `update_counters`, which moves no timestamp, so a row whose children changed is
  one `MAX(updated_at)` still calls unchanged: an agent who claimed two contacts went on
  reading `0 contacts` until something else wrote to the agent.

  The counts go in the key beside the version. They are read off the rows already in memory,
  so this costs no query, the way reading that version costs none.

## 5.6.1 - 2026-09-18

* [Change] The pinned bundle is `houseaccount@0.14.2`

  A conversation reads at the house's own size wherever it is drawn, a bubble inside a flow
  is read from its start, and a focus ring is no longer painted over by the link below it.
  These pages compact their body type for tables dense with figures, which is what made the
  first of those visible here.

## 5.6.0 - 2026-09-18

* [Feature] A table can be dragged into an order

  Back from the 4.0.0 development tree, and opting in the way the map and the calendar do:
  a model keeping an integer `position` is one a reader positions by hand. A grip opens each
  row, dragging it moves the row, and `resource :position, only: :update` is where the place
  it landed is written. That route is drawn where the host asks for it —
  `recourses :steps, positionable: true` — and nowhere else: a table is put in order from
  its index, so the keyword is refused on a resource that draws none. The column still
  decides everything else, `recourse_order` among it, because the order a table is read in
  and the order somebody put it in are one fact.

  The type is load-bearing rather than belt-and-braces, and asked through
  `type_for_attribute` as a calendar asks about its two ends: `contacts.position` holding a
  job title is a word about the row, not a place among rows. A map and a calendar only
  read, so a column mistaken for one costs a link; this writes, and writes at the first
  save.

  Two things follow the column rather than the routes. `Recourse::Positionable` fills the
  column on create and closes the gap on destroy, so a row made in a console is numbered
  like one made behind a form — what a drop reports is a row's place on the *page*, which
  is a position only while the numbers run 1, 2, 3 with no holes in them. A model pointing
  several ways answers `recourse_siblings` with the rows one of its own is counted among;
  one pointing a single way needs no answer, and one pointing nowhere is positioned among
  the whole table.

  Whether a page is positioned is asked per page, not per model: a place means something
  under the parent it is counted within, so a flat model's own index is positioned and a
  listing of every row across every parent — where the positions run 1, 2, 3, 1, 2, 3 side
  by side — is not. And the search box and the sorted headings stand down while the grips
  are drawn, a `q` typed by hand refused with them: a filter shortens the page, and a drop
  on a shortened page reports a place among the rows that are left.

  A host keeping the order itself writes `def recourse_position = nil`. A host with a
  second listing of a positioned model names the second column on its own controller, which
  then owns the write as well as the page — `Recourse::PositionsController` is public to
  subclass, and `Recourse::Positioning` is public for the column such a host maintains.

* [Fix] A word that names a class which is not a model

  `known_title` guarded against a name resolving to nothing — `pause` is a verb no app
  makes a class for — but not against one resolving to a class with no `model_name`. A
  host may keep a plain `Message` that gathers rows rather than a table of them, and a
  breadcrumb over such a page raised instead of reading. It asks whether what it found
  answers `model_name`, the way `known_icon` beside it already does.

* [Feature] `Recourse.assets` says where the house bundle is served from

  The stylesheet, the script and the palettes were three URLs carrying one pinned version,
  moved together by hand every release — the 5.5.0 entry below says as much. They are one
  line now: `Recourse::BUNDLE` is which release, `Recourse.assets` is where it is read
  from, and jsdelivr's copy of the published package stays the default.

  A host that sets `Recourse.assets = ''` serves the bundle itself, out of the
  `houseaccount` gem mounted by path: its engine answers `/css`, `/js` and `/theme` from
  its own `public/`. That is how a stylesheet or a controller gets tried on a real page
  before the version carrying it is published, which is what this release needed.

* [Change] The pinned bundle is `houseaccount@0.14.0`

  What carries the `sortable` controller the feature above names, and the two rules beside
  it: the grip's cursor, and the tint on the space a dragged row will land in.

## 5.5.0 - 2026-09-17

* [Fix] A sorted heading has a mark again

  The mark saying which way a column is sorted was a Bootstrap caret, and no caret is in the
  icon font the pages link: the bundle carries a subset, and a name outside it gets no
  `content` rule and no code point, so the `<i>` drew nothing at all. Since `design_assets`
  every sorted heading has been bare, and the test asserting the mark passed throughout,
  because what it asserts is a class name.

  It is `unicon`'s `:sort_asc` and `:sort_desc` now, drawn through `icon_tag` like every
  other icon here rather than by a class written out. Bootstrap draws them `sort-up` and
  `sort-down` — named for the ordering rather than the arrow, since Bootstrap's four sort
  glyphs point either way with either ordering. Both draw from the bundle this release
  pins, whose subset carries `sort-up` beside the `sort-down` it already held.

* [Change] The pinned bundle is `houseaccount@0.13.0`

  Two releases at once, since the pin was still at 0.11.0 while 0.12.0 came and went. It is
  what carries the ascending sort glyph, so the fix above needs it; it also brings a card
  that is as wide as what it holds, a form reading its rows from where their words start,
  and a combobox the bundle searches. Moved at all three sites together — the layout's
  stylesheet and script, and `THEMES_PATH`.

## 5.4.0 - 2026-09-17

* [Feature] A table of events can be read as a week

  The second shape a page of rows can take, beside the map: a model keeping a `starts_at`
  and an `ends_at` offers `Display as calendar` in its footer, and `/shifts.cal` draws
  them as a week — a column a day from Sunday, the hours that week's own rows cover down
  the side, and each row placed by the share of the day it takes, in a lane of its own
  where a day's rows overlap, saying what it is, whoever it points at and the hours
  themselves. The grid is as tall as a table's own first page, so the two shapes carry
  their footers at one height. A week rather than a page is the unit, so `?week=` moves it
  and `<<`, `<`, `>` and `>>` stand where a table's pages stand — a week either side and
  four weeks beyond each — with the week named between them;
  the search, the filters and the reader's own time zone all travel with it. A search or
  a filter now answers in the shape it was picked in rather than falling back to the
  table, and `Display as map` and `Display as table` are drawn by one helper, so a model
  earning both shapes offers both.

## 5.3.0 - 2026-09-16

* [Feature] A record's files are a field, a value and a page

  Back from the 4.0.0 development tree: a `has_one_attached` is a file field on the form
  and a value on the record's page, a `has_many_attached :photos` beside
  `recourses :photos, only: %i[index destroy]` under the record is a table of Active
  Storage's blobs — searched, sorted and paged like any other — and a submitted file is
  attached after the save rather than assigned, so an edit that touched only a name never
  purges what the record had. New this time: a file a browser can be shown is a picture
  first, a `<picture>` 100 pixels tall of a representation made 200 tall — WebP at quality
  80 with its metadata stripped where the browser takes it, the file's own kind where not
  — in the link that opens the whole file inline — the image scaled, or the frame a
  previewer takes of a video or a PDF where the host has `ffmpeg` or `poppler` — on the
  table and on the record's page alike. And a Delete on each row of the table, which
  takes the file off the record and leaves the blob to Active Storage. Files are still
  added on the record's form, and a shelf is still not counted on its tab: there is no
  `belongs_to` to hang a counter cache on.

* [Feature] A table routed `destroy` without `edit` offers Delete on each row

  The Delete button stood on the edit page and nowhere else, so a resource with a
  `destroy` and no `edit` — a file attached to a record, a row joining two — had no way to
  be deleted from the gem's own screens. Its table now draws a third action column, the
  trash icon in `fg-danger`, a `button_to` carrying the same confirmation the edit page's
  button does. A table whose rows have an edit page is unchanged.

* [Fix] A filter narrows a table again

  A combobox became a `<select>` in 5.0.0 and its picks are submitted one value each, but the
  search read them the way it read the comma-joined string before it — so `q[team_id_in][]=1`
  arrived as the array `["1"]`, was written out as the one value `["1"]`, and was cast to the
  id 0 no row holds. Every filter menu in the gem came to an empty table, whatever was ticked.
  The picks are now taken as the values they arrive as, and `All …`, which submits one empty
  value, is no filter rather than a filter nothing answers.

## 5.2.0 - 2026-09-14

* [Feature] A table of places can be read as a map

  A model keeping a `google_place_id`, or a `latitude` and a `longitude`, earns a second
  shape for its index: `/counties.map` draws the page on a Google map, in the frame and
  over the footer the table has, so the search, the sort and the pages work the same on
  either. The footer under the table offers `Display as map` and the one under the map
  `Display as table`, each keeping the page the other was on. A place ID is filled in as
  an area where the model is a geography Google draws boundaries for — a `State`, a `County`,
  a `City` or a `ZIP`, by name — and pinned at the place for any other model; a point is
  pinned as it is. The key and the map style, with those
  layers turned on, are read from the host's credentials under `google_maps` as `api_key`
  and `map_id`. `.map` is registered as a name for HTML, and the index renders its HTML
  templates for it. The design bundle is pinned at v0.5.0, which carries the `map`
  controller.

## 5.1.0 - 2026-09-14

* [Feature] The head past the gem's own tags is the host's, through a `recourses/head` partial

  The layout named a host's icon under the four file names a Rails app might ship one at,
  and fetched every one, three of them a 404 on a host that keeps its icons elsewhere. It
  now renders `recourses/head` where a host — or a gem the host loads — provides one, and
  writes no icon link of its own where nobody has. A host whose tab went blank writes its
  icon links into that partial.

## 5.0.1 - 2026-09-14

* [Fix] A required combobox starts empty rather than on its first option

  A `<select>` left to itself picks its first option, so the toggle read a choice nobody had
  made and a form could be sent with it. A single select without an unset option now leads
  with a placeholder nobody can pick, so the box says `Select…` until a reader chooses.

## 5.0.0 - 2026-09-14

* [Breaking change] Every page is styled and scripted by `https://design.houseaccount.com`, and nothing is served by the gem

  The vendored Bootstrap, its icons and fonts, Stimulus, the sixteen controllers, the nine
  palettes and the layout's own stylesheet have moved to the `design` repo, which publishes
  them at `/v<version>/css/houseaccount.css`, `/v<version>/js/houseaccount.js` and
  `/v<version>/theme/<name>.css` on that origin, kept forever per version. The layout links
  the first two at a pinned version, and `Recourse::THEMES_PATH` names the third at the
  same one; a fix there reaches these pages when the pin moves, and not before. The
  `Rack::Static` layers under `/recourse/` are gone with the files they served.

  A host needs that origin reachable from its readers' browsers. A host with a Content
  Security Policy allows it for `style-src`, `script-src` and `font-src`. A host on the
  `houseaccount` gem serves the same paths itself, but this gem still links the site: it
  never names that gem.

* [Breaking change] A combobox is a `<select>`, and a filter submits one value per pick

  `_combobox.html.erb` renders a plain select carrying its words as data attributes, and
  the design bundle dresses it as Bootstrap's combobox; the toggle, the menu and the
  plugin's hidden input are no longer in the page. A filter's select is `multiple` and
  named `q[status_in][]`, so a request carries `q[status_in][]=draft&q[status_in][]=sent`
  rather than one comma-joined value — a host linking to a filtered index, or reading
  `params[:q]`, updates the shape. A host overriding the partial rewrites it as a select.

* [Feature] The delete dialog is the bundle's

  `_confirm.html.erb` is gone: `confirm.js` in the design bundle builds the dialog on
  the first ask, and its answer wears the words of the button that asked. A host that
  overrode the partial deletes its copy.

* [Fix] A phone is formatted in the browser

  A cell reads `<span data-controller='phone'>4155550000</span>` and a field arrives with
  ten digits, the controller and nothing about its shape: no `pattern`, `placeholder` or
  `title`. The design bundle's controller decides `555-555-5555` in both places. A host
  asserting the formatted number in its own tests updates the assertion.

## 4.8.0 - 2026-09-13

* [Feature] A table is redrawn when a record its rows draw changes, so a `touch: true` kept for that alone can go

  A cell naming a key draws the record it points at — a booking's row reading its
  contact's phone — and the relation's own version, `COUNT(*)` and `MAX(updated_at)`
  over the page, sees only the rows themselves. The table kept the number the contact
  had when the fragment was written, until somebody wrote to the booking. The key now
  carries the newest `updated_at` among everything `recourse_includes` names, which
  the index eager-loads already — so it is read off the records in memory and costs no
  query.

  A host that declared `belongs_to ..., touch: true` to expire such a table can drop
  it: a touch is an UPDATE per parent per child write, it contends on the parent row,
  and it makes every child write look like a parent update to every `after_commit` the
  parent has. One that says a domain fact — a parent genuinely updated by its child —
  stays. Where a row of a host's own reads through a second key, name that in
  `recourse_includes` as a hash, the shape `includes` already takes, and the version
  follows it there.

## 4.7.0 - 2026-09-11

* [Feature] The toast after a create or an update names the record and links it to its page

  `Blue Crew was updated.` rather than `Team was updated.`, with the label led to the
  record's show page where the routes drew one, so a reader can go and look the row over.
  The words are the label the model picked, or the model's own name where a record says
  nothing. A rejected write and a delete still name the model. A host asserting the old
  wording in its own tests updates the sentence.

* [Feature] The first click on a heading sorts the table downward, and the second turns it back up

  The newest, the most and the latest are what a reader clicks a heading to find, and
  ascending put them on the last page. A host asserting a heading's `asc` link in its
  own tests now reads `desc`.

## 4.6.5 - 2026-09-09

* [Fix] A table opens at 15 rows a page rather than 20; the 100-row page stays

## 4.6.4 - 2026-09-08

* [Fix] On a phone the arrows that put the words back reload the page outright: the visit 4.6.1 made to the same address was morphed in place under an index's refresh metas, and Safari drew the sidebar's entries one over the next all the same

## 4.6.3 - 2026-09-08

* [Fix] The gem's scripts and stylesheets are revalidated on every full load, so a browser runs the version the host deployed rather than the one it fetched hours ago

## 4.6.2 - 2026-09-08

* [Fix] A filter menu on a page under a record no longer counts each option: the counts were of the whole table, not of the record's share of it

* [Fix] A counter's tooltip stays away on a phone that reports a coarse pointer, where a tap on `Franchises: 11` flashed it before the page changed

* [Fix] A filter's menu is no longer cut off at the foot of a short page — one whose table has no rows — on a phone

## 4.6.1 - 2026-09-08

* [Fix] On a phone the arrows that put the words back ask for the page again rather than reshaping it in place, which in Safari left the sidebar's entries drawn one over the next until a reload

## 4.6.0 - 2026-09-08

* [Fix] On a phone the `Displaying items` sentence is centered over the pagination links, which already were

* [Feature] A phone reads the chrome as icons, and a pair of arrows at the foot of the sidebar puts the words back

  The sidebar is one centered row of icons at the very top of the page, above the trail;
  a crumb is its icon, a tab its icon and its figure, the foot's controls their icons. The
  words are there for a screen reader, and for anyone who taps the arrows: they write a
  `recourse-density` cookie and the server draws every page with the words beside the icons
  until the next tap. A column at 768px and wider is unchanged. The arrows on that control
  are unicon 3.6.0's `:expand` and `:collapse`, which the gem now requires.
* [Feature] On a phone, a page under a record puts its search form and its buttons on rows below the trail

  Two or three crumbs left the form the width of `Filter by na`. An index at the top of
  the sidebar keeps its form beside its one crumb.

* [Feature] `Recourse.theme` draws every page in one of eight editor color schemes, and the sidebar's moon rotates through them

  Back from recourse 4's development tree, where it was cut for the release: Dawn,
  Dracula, Gruvbox, Monokai, Nord, One Dark, Solarized and Tokyo Night, each a
  stylesheet served from the engine that repaints Bootstrap's ramps in both modes, with
  Bootstrap's own palette named `:bootstrap` beside them. A click on the moon or the sun
  moves the page to another palette and into the other mode, and the reader's choice is
  kept in their browser. `Recourse.color` still names the primary family on top of any.

## 4.5.0 - 2026-09-08

* [Fix] A row with a bookmark square is as tall as a row without one: the square no longer claims a button's minimum height

* [Feature] The arrow after a web address opens it in a new tab, while the words still open it in this one

* [Fix] A production rake task boots without Rails 8.2 warning that Action Controller and Active Record were loaded early

  `recourses` defined each missing controller as the routes drew, which loaded the host's
  `RecoursesController` and everything above it, and asked a nested name for its model the
  same way. A boot that will not eager load — a `db:migrate` on release — draws its routes
  before it is done, and Rails 8.2 logs a warning for every component loaded then. The
  controller now waits for the app's first request or job, and the model is looked up as a
  constant, without loading it.

## 4.4.4 - 2026-09-08

* [Fix] On a phone the search form keeps its place beside the breadcrumb once a filter is picked

  A form sized by its content widened with the words a picked option put on a toggle
  and wrapped under the crumbs.

## 4.4.3 - 2026-09-08

* [Fix] A counted tab reads `1 franchise` again, without the extra space 4.4.0 put between the figure and the word

## 4.4.2 - 2026-09-08

* [Fix] `search_highlight` marks the label of a record the search reached through a key

  A row drawn out of the provider a sector points at marks `provider.name` with
  `search_highlight provider.name, :name`; the helper checked `name` against the
  sector, which has none, and marked nothing.

* [Fix] On a phone the pages under a table are centered on their own row
* [Fix] A filter's menu drops over the sidebar's row of links on a phone, not under it

## 4.4.1 - 2026-09-08

* [Fix] The footer reads `Displaying items 1-20 of 101`, without `in total`

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


