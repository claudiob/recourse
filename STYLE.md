# Design Guidelines

**Scope:** how the pages this gem serves look and are marked up. `CLAUDE.md` is
the authority for code style; this file is the authority for design. Read it
before writing or editing any layout, view or partial.

## Bootstrap 6 Alpha for all markup

- Every layout, view and partial follows Bootstrap 6 Alpha conventions.
  Reference: https://v6-dev--twbs-bootstrap.netlify.app/llms-full.txt
- Check class names against those docs rather than recalling Bootstrap 5. v6
  renames and removes plenty: responsive utilities are prefixed
  (`md:col-6`, not `col-md-6`), `.bg-light` / `.bg-dark` are gone in favour of
  the `.bg-1` / `.bg-2` scale, and `.text-body-secondary` is now `.fg-2`.
- Page wrappers use `.container-fluid`, never `.container`. A table wants the
  whole width on a desktop, not a centred column with margins either side.
- Still current from v5: `.container-fluid`, `.table`, `.table-responsive`, and
  `data-bs-theme="light|dark"` for color modes — though `color-scheme: light
  dark` on `:root` follows the system by default, so most pages need no theme
  attribute at all.
- The gem ships `app/views/layouts/recourses.html.erb`, and every screen it serves
  renders in it: Bootstrap's CSS in the head, the JS bundle as a module before
  `</body>`, and no webfont: text is `helvetica, verdana, arial, sans-serif` at
  14px (`0.875rem`, so a browser's text-size setting still scales it), set
  through `--bs-body-font-family` and `--bs-body-font-size` in the layout's own
  `<style>`. Nothing on the page reaches an external host.
- Named for the controller rather than for the app. `RecoursesController` implies
  `layouts/recourses` and finds it in the gem before Rails falls through to
  `layouts/application`, so a host's own layout is not involved — and a host with no
  layout of its own is not left rendering *its* pages in this one, which is what
  shipping `layouts/application` did.
- A host puts its chrome back by writing `app/views/layouts/recourses.html.erb` of
  its own, which wins on being earlier in the view paths, or by declaring
  `layout 'application'` on a controller that subclasses `RecoursesController`.
- Bootstrap is *vendored*, not linked. `vendor/recourse/` holds
  `bootstrap.min.css`, `bootstrap.bundle.min.js`, `bootstrap-icons.min.css` and
  the two icon fonts, and the layout asks for `/recourse/…`. A CDN that moves or
  goes down would otherwise take every page's styling with it, and the Bootstrap
  6 CSS is served from a preview host rather than a release one.
- The icon fonts are not optional extras. `bootstrap-icons.min.css` reaches for
  `fonts/bootstrap-icons.woff2` beside itself, so vendoring the CSS alone leaves
  every icon a blank box.
- The engine serves them with `Rack::Static`, since a host may run no asset
  pipeline at all — see CLAUDE.md, "Vendor what a page cannot render without".

## The primary color

- Bootstrap's primary is blue, and `Recourse.color` is what changes it — nil by
  default, and one of `blue`, `gray`, `orange`, `purple`, `pink` or `brown`.
- Six of the sixteen families. The other ten are declined rather than forgotten,
  and anything else raises.
- Never restyle a component to recolor it. `.theme-primary` maps all nine
  `--bs-primary-*` properties onto `--bs-theme-*`, so redefining those nine is what
  carries a color to every button, link, sorted heading and focus ring at once.
- The nine live in `_color.html.erb`, copied from `bootstrap.min.css` in upstream's
  order and upstream's shapes with only the family swapped — including the
  two-branch `light-dark` focus ring, which is worth keeping verbatim so a later
  Bootstrap can be diffed against it.
- The block goes *after* the stylesheet link in the head. Both selectors are
  `:root`, so it wins on being later and nothing else; put it before and it does
  nothing at all.
- `--bs-primary-contrast` is the one of the nine that names a *color* rather than
  a family. It is `var(--bs-white)` or `var(--bs-gray-975)`, decided per family by
  `Recourse.ink` and handed to the partial as its second local. Both are shapes upstream ships:
  Bootstrap gives `warning` and `info` a dark label for the same reason.
- The floor is 3:1, WCAG's for a UI component, and it is not 4.5:1. A solid button
  is filled from the 500 step, where 4.5:1 is unreachable for a mid-lightness hue —
  Bootstrap's own blue is 3.56:1 against white — so no page here claims AA for a
  button label. Say 3:1 and mean it; a host needing AA fills from the 700 step.
- Never assume white. White on `orange-500` is 2.90:1, and `orange` is one of the
  six: the ink is computed, and the computation is what keeps it honest.
- A host wanting the ten overrides that partial. It takes the family and its ink as
  its two locals, so a host's version can ignore both entirely.

## The scheme toggle

- The sidebar ends with the reader's own controls: a moon while the page is light and a
  sun while it is dark, and — where the host drew a route named `exit` — the way out
  beside it. They share the last `.nav-item`, `.recourse-foot`, a flex row in which each
  control is half the width and centers its icon: the toggle alone sits in the middle,
  and the two together sit at a quarter and at three quarters. While the sidebar is a
  row the foot is simply the last thing in it; while it is a column the layout's rules
  take it to the bottom and stretch it across.
- Those rules are written out rather than reached for as utilities, and both halves are
  load-bearing. `.nav-item` ships `flex: auto`, so in a nav given a height every item
  takes an equal share of it and an auto margin is left nothing to push against: the
  items are pinned to `flex: 0 0 auto` and only the foot's margin takes the rest.
  Same reason the sidebar's own borders are written out — see the note there.
- Not sticky. The foot rides on the fold while the links leave room and comes to rest
  under the last of them once they do not, to be scrolled to like anything else.
- A hover tints the control's background with `--bs-bg-1` under a rounded corner, the
  same tint the combobox's clear button takes: a hand cursor alone says little on an
  icon, and a tint says it is a control.
- The icon names where a click *goes*, not where the page is: a moon on a light page,
  a sun on a dark one.
- Both icons are drawn and CSS shows one, because nothing in Ruby knows which mode the
  page is in — until a reader clicks, there is no attribute and the mode is the
  system's. Three states, so the rules read: no attribute plus a `prefers-color-scheme`
  query, then `[data-bs-theme='light']`, then `[data-bs-theme='dark']`.
- The mode is forced with Bootstrap's own `data-bs-theme` on `<html>`, which sets
  `color-scheme` and so decides every `light-dark()` on the page — and brings
  `--bs-shadow-strength` with it, which a hand-rolled attribute would not.
- Forcing dark also brings Bootstrap's `[data-bs-theme=dark]` navbar tokens, which are
  v5's `.navbar-dark`. So a page dark by the toggle and a page dark by the system are
  not quite identical in the navbar. Upstream's behaviour, and both read correctly.
- The reader's choice is kept in their browser, never on the server: it is theirs, and
  a mode is not something a page needs to be told twice.
- It is put back by an inline classic script in the `<head>`, not by the controller. A
  module is deferred and a controller connects after the first paint, either of which
  would show the system's mode for an instant and then swap it.
- And the controller says it again on `connect`, because Turbo merges the `<head>` on
  a visit. The sidebar is redrawn every visit, so connecting is the moment that catches it.
- A value read back out of storage is checked before it reaches the page, in both
  halves. The storage is the reader's own, which is not the same as trusted.

## The navbar

- Every page opens with a navbar holding a breadcrumb, then `yield :actions`,
  both to the left, and `yield :search` pushed to the right by the form's own
  `ms-auto`.
- The breadcrumb ends at the current page, and that last item is *not* a link:
  a `<span class='breadcrumb-link active'>` inside an
  `<li class='breadcrumb-item' aria-current='page'>`. Bootstrap's own example
  uses an `<a>` there; we deliberately do not.
- Earlier items are links and carry the resource icon — or none at all where
  Unicon has never heard the model's concept: no picture beats the fallback
  circle, which pictures nothing. The sidebar reads through the same label, so
  it goes without in the same case. Separated by empty
  `<li class='breadcrumb-divider'>` elements — v6 draws the chevron from that
  element, not from a CSS `content` string on `::before` as v5 did.
- An index has one item, its own name. Any other page links back to the index
  first and then names itself: `/counties/new` reads `Counties` as a link, then
  `New county` as plain text.
- A view contributes buttons with `content_for :actions` and its search form with
  `content_for :search`; the layout only yields. Nothing else belongs in the
  navbar.
- Where they go is the layout's decision, and the gem's own layout is the one that
  makes it: the navbar, with the search pushed right. A host that replaces
  `layouts/recourses` and yields neither gets no buttons and no search box, the same
  way it gets no styling until it links the stylesheets — the gem's layout is what
  such a layout is modelled on.
- A breadcrumb link and its sidebar twin line up vertically, which constrains
  both. The `<nav class='navbar'>` carries no horizontal margin or padding of
  its own, so both columns reduce to `container-fluid` (0.75rem) plus a link
  padding of 0.75rem — the sidebar's own 0.75rem container padding is cancelled
  by `.row`'s negative margin. Adding `px-*` or `mx-*` to the navbar shifts the
  breadcrumb out of line by exactly that much.
- `.breadcrumb-link` needs `gap-2`. Both link types are flex, but only
  `.nav-link` ships a `gap`, and a whitespace-only text node is not a flex item
  — so without it the breadcrumb's icon and text would touch while the
  sidebar's sit 0.5rem apart.
- A crumb that is not a link keeps its resting colors on hover: Bootstrap lights
  every `.breadcrumb-link` under the cursor, which on a `<span>` promises a
  click that goes nowhere. The layout redefines the two
  `--bs-breadcrumb-link-hover-*` tokens on `span.breadcrumb-link` — the element
  is what tells a link from the rest, since a crumb that links is an `<a>` — and
  gives the `.active` span its own resting color back, rather than out-cascading
  Bootstrap's hover rule.
- Whatever shares that line sits vertically centred on it, and what separates a
  line from the next one is the container's `row-gap-2` rather than a margin on
  anything in it. A margin is there whether the item wrapped or not, so the
  `mt-2 md:mt-0` the search form used to carry dropped the field a few pixels
  below the breadcrumb at every width where the two still shared a line.
- Every control in the navbar is the small size, since it shares a line with a
  breadcrumb: `btn-sm` on a button, `form-control-sm` on a field, and
  `form-control-sm` on a combobox toggle, which is a `<button>` wearing
  `.form-control` and takes the same class. The combobox partial gets there
  through a `small:` local, so the same partial draws a full-size one inside a
  form and a small one in the navbar.
- An index offers `Add <resource>` only when there is somewhere to go: the
  `new` route has to be drawn *and* the controller has to implement the action,
  or the button would 404 or raise. Its classes are
  `btn theme-primary btn-sm btn-outline ms-3`.
- Where `create` is routed with no `new`, the same spot holds a `Create` button
  instead: a `button_to` posting the record whole — `.btn-solid`, being a button
  and not a link dressed as one — in the Add link's size and color, with the
  `ms-3` on its form, which is the flex item. Routing it that way is the host's
  word that a bare record can stand — the gem checks nothing further.

## Deleting a record

- The delete lives on the edit page and nowhere else, contributed with
  `content_for :actions` so it sits beside the breadcrumb. Not in the table: a
  row of pencils with a bin beside each is a mis-click waiting to happen, and the
  warning below is only worth writing if it cannot be bypassed.
- The bookmark square is in a table and asks nothing, which is not a breach of that
  but the reason for it: what keeps a delete off a row is that a mis-click cannot be
  taken back, and a mis-clicked bookmark is taken back by clicking again.
- It is a `button_to` rather than a link, since a delete is not a GET, wearing
  `btn btn-sm btn-solid theme-danger ms-3` — solid, because it is a real button
  and `.btn-outline` is the navbar's dress for links; danger, because this one
  is different; and the same solid danger the confirm dialog's own Delete wears.
  Its form takes `d-inline-block`, or it would break the navbar's line.
- It appears only where the `destroy` action is implemented *and* routed, the two
  guards `Add <resource>` and the edit pencil already answer to.
- It asks first, through `data-turbo-confirm`, and the wording is settled in
  CLAUDE.md rather than here — the text names the record, counts a level of what
  goes with it, says what is kept instead, and ends `This cannot be undone.`
- The count stops at one level on purpose. Every `has_many` costs one `COUNT` on
  an indexed key; counting a state's whole subtree means joining 40,965 ZIPs to
  render an edit page, so `Anything under those goes too` stands in for the rest.
- The warning shows in a Bootstrap 6 Dialog — v6's rename of Modal, built on the
  native `<dialog>` element, whose `showModal()` brings the focus trap, Esc and
  the top layer for free — never in the browser's own `confirm()` box.
  `Turbo.config.forms.confirm` is the hook, assigned in the layout; the wording
  still travels in `data-turbo-confirm`, unchanged, and the dialog is only how it
  is displayed.
- The markup is `recourses/_confirm`, rendered once by the layout after the
  flash, empty: `/recourse/confirm.js` fills the title with the message's first
  line and the body with a `<p>` per remaining line — `textContent`, never
  `innerHTML`, because the title carries a record's name and a name is data.
- `dialog-slide-down` is the animation, shipped by v6 — no CSS of ours — and
  reduced-motion turns it off in the same stylesheet.
- The footer reads Cancel then Delete: Cancel is `btn btn-solid theme-secondary`
  with `data-bs-dismiss='dialog'` and `autofocus`, so Enter lands on the safe
  answer; Delete is `btn btn-solid theme-danger` with `recourse-confirm-delete`
  as its JavaScript hook, unstyled.
- Cancel, Esc and a click on the backdrop all answer no, through one
  `hidden.bs.dialog` listener; only the Delete button answers yes.
- Turbo is what asks. Under a host layout that does not load it the button still
  deletes, with nothing asked first — the same bargain as everything else the
  gem's own layout brings — and one that loads Turbo without this layout's hook
  gets the browser's `confirm()` back, which is the graceful floor.

## Icons on resource links

- A link to a resource is preceded by a Bootstrap Icon, using the `<i>` form:
  `<i class='bi bi-person-rolodex'></i> Contacts`. The layout loads
  `bootstrap-icons@1.13.1`.
- Which icon is the *model's* to say, through `recourse_icon`, and never a list
  kept here. That list existed in two places — a map in `lib/recourse/icons.rb`
  and a copy of it in this file — keyed by the title as it displayed, so a
  resource renamed anywhere lost its picture silently.
- A model names a *concept* rather than an icon: `:train`, not `train-front`.
  `Unicon` says what that concept is called in Bootstrap Icons, and in SF Symbols
  and Material Symbols for whatever draws these records next.
- The default is the model's own name, so nothing has to be declared to be right:
  a `Contact` draws `person-rolodex`, a `Job` a hammer, a `Booking` a
  calendar-check. All sixteen models in the dummy app land on the icon the old
  map had chosen for them by hand.
- `def recourse_icon = :bag` in the model overrides it, for when the concept a
  model is named after is not the concept it means.
- A name Unicon has never heard of draws a circle rather than raising, which is
  what the old `FALLBACK_ICON` did and one fewer thing for this gem to hold.
- The breadcrumb's current page carries its icon too, though it is not a link:
  `/locations` reads as the pin and then `Locations`. It needs `gap-2` for the
  same reason a link does — only `.nav-link` ships a gap of its own.
- A crumb naming a page rather than a resource gets none. `New market` is not a
  thing with an icon, and the crumb before it is already showing the market's.
- The record a nested page stands under is a crumb of its own — `Counties`, then
  `Autauga County`, then `ZIPs` — linking to the record's show page where one is
  routed, and plain text where none is. Icon-less either way: it names a record,
  and the crumb before it already carries the resource's.
- The tab wears the *host's* icon, not the resource's. The layout declares the four
  names a Rails app ships one under — `/icon.png` and `/icon.svg`, which Rails 8
  writes, and `/favicon.ico` and `/favicon.png`, which an older app has — and the
  browser takes the first it can fetch. The gem draws no glyph of its own: a browser
  picks one `rel='icon'`, so a per-resource tab and an app's own tab cannot both win,
  and the app's is the one a reader recognizes.

## The sidebar

- Below the navbar, an `<aside>` sits to the left of the content holding a
  vertical `ul.nav.flex-column` of links — one per resource `recourses` drew.
- The order is the order `config/routes.rb` declares them, never sorted.
- The entry for the page being shown is `nav-link active` with
  `aria-current='page'`. It is matched on the controller, not on the URL, so
  `/contacts?page=2` still marks Contacts active.
- A resource appears only if its `index` action is routed. `recourses :drafts,
  only: :new` draws no index, so it gets no link rather than a broken one.
- Layout is `.row` with `aside.col-12.md:col-auto` and `main.col-12.md:col`,
  inside the page's `.container-fluid`. Below 768px each is a full-width row of
  its own, so the sidebar sits under the navbar and the content under that;
  from 768px they are the two columns again, unchanged.
- Stacked, the links run across rather than down: the `ul` is `nav md:flex-column`,
  and a plain `.nav` is a wrapping flex row.
- The rule between the sidebar and what it sits against follows it around —
  `border-block-end` while it is a band under the navbar, `border-inline-end`
  once it is a column beside the content. v6 generates no responsive border
  utilities, so `.recourse-sidebar` writes both out in the layout's `<style>`
  rather than the aside carrying `border-end`.
- The aside's border runs to the bottom of the window. That takes a chain of
  three: `body.d-flex.flex-column.min-vh-100`, then
  `.container-fluid.flex-grow-1.d-flex`, then `.row.flex-grow-1`. The aside
  stretches because `.row` is a flex container and Bootstrap leaves
  `align-items` unset, so items default to `stretch`.
- Above 768px that same chain is what pins the chrome. `.recourse-shell` is `height:
  100dvh` rather than a minimum, so the shell is the window and nothing about the page
  can make it taller; `main` and the aside take `overflow-y: auto`, so each scrolls
  itself and the navbar and the sidebar stay put however long the table is. Every link
  in the chain needs `min-height: 0` — a flex child is as tall as its content unless
  told otherwise, and one of them left alone pushes the shell past the screen and hands
  the scrolling back to the window. `min-height` is set on the shell too, since
  `.min-vh-100` is the same specificity and only loses on order.
- And the row stops wrapping above that width, which is the half that is easy to miss:
  a wrapped flex line is as tall as the tallest item on it, and `align-items: stretch`
  only ever grows an item to the line it is on — it never shrinks one to fit. So with
  the row left wrapping, `main` kept its content height, the line grew to match, and
  the page scrolled after all, however bounded everything above it was.
- Every one of those rules names the row by the path down to it —
  `.recourse-shell > .container-fluid > .row` — and never as `.recourse-shell .row`.
  There are other rows inside the shell: a show page lays its values out in one and a
  form lays its fields out in another, both inside `main`. A descendant selector
  reaches them, and `flex-wrap: nowrap` on a row of `lg:col-6` values is three of them
  squeezed onto one line where there should be two rows of two. The row this is about
  is the only `.row` that is a child of that container, so the path says exactly it.
- Below 768px none of it applies: the sidebar is a band across the top, and a phone
  scrolls the page as one.
- Only while they are one line, though: the row is
  `align-content-start md:align-content-stretch`. Stacked, the sidebar and the
  content are two lines of a wrapping flex row, and `align-content: stretch`
  hands each of them half of whatever height the page has left over — a band of
  empty space under a dozen links, and the rule stranded well below them. Packed
  to the top instead, they sit against each other; from 768px the single line is
  stretched again, which is what draws the rule the whole way down.
- `min-height` rather than `height`, so short pages fill the window without a
  scrollbar and long ones still scroll.
- Every entry answers to a letter of its own title, held with Option: `Contacts`
  to C, `Counties` — declared after it — to O, since C was taken. The letter is
  the first one in the title nothing above it has claimed, which is what makes
  the hint below able to point at it rather than at a number nobody can guess.
- Holding Option marks that letter in place: `C` in `Contacts` and `o` in
  `Counties` gain a weight and an underline. Marked rather than bracketed —
  `[C]ontacts` would shift every entry two characters wide the moment the key
  went down, and a sidebar that jumps is a worse hint than one that does not.
  The bracketed form is two commented-out rules in the layout for whoever wants
  it.
- Option, not Control or Command: both of those are spoken for by the browser and
  the system — Control+C and Command+C are copy — while Option is what a
  browser's own `accesskey` reaches for on most platforms.
- The marked title is wrapped in one element, and that is not decoration.
  `.nav-link` is a flex container with a `gap`, so a bare `<span>` around the
  letter would make three flex items of `C`, `o` and `unties` and put the gap
  between each — the entry would read `C o unties`. One wrapper is one item, and
  inside it the word is an ordinary word again. The same trap as the breadcrumb's
  `gap-2` above, from the other side.
- The key is matched on `event.code`, not `event.key`. On a Mac, Option+c is `ç`,
  so the character produced says nothing about which key was pressed.
- The link is `click`ed rather than followed by assigning a location, so the
  visit is Turbo's like any other, and the `accesskey` attribute is deliberately
  not set: the browser would activate the same link a second time.

## The card a record sits in

- A record's pages — `show` and `edit` — put their content in a `.card` whose
  `.card-header` holds a `ul.nav.nav-tabs.card-header-tabs`, one tab per page the
  record has. `card-header-tabs` is what pulls the row up into the header's padding,
  so the active tab meets the body it belongs to instead of floating above it.
- The body takes `align-items-stretch`. A `.card-body` is a column flex container
  that packs its children to the start, so a form of two fields would be as wide as
  two fields rather than as wide as the card, and its grid would stop halfway across
  the page. Stretched, every page fills the card whatever it holds: two columns of
  equal width, or one field taking half the row.
- Tabs are *links*, not a JavaScript tab set: each is a page of its own, with its own
  URL and its own breadcrumb. The current one carries `.active` and
  `aria-current='page'`, the same pair a sidebar entry uses.
- A look before a change, the order the seven actions are drawn and the order the row
  links follow. Each tab wears that link's icon — the eye and the pencil — from one
  `ICONS` map, so a row and a card cannot come to disagree about which is which.
- After them, one tab per resource nested under the record — in the order routes.rb
  nested them, the same order the sidebar keeps, never the associations' — and the
  nested index is the whole requirement. A nesting with none is an action rather than a
  page, and its button stands
  beside the breadcrumb instead — wearing `btn theme-primary btn-sm btn-solid`, the
  same dress as the index's bare `Create` it is the sibling of, and solid for the same
  reason: it performs rather than navigates.
- An index tab wears the counted model's icon where a `has_many` of that name answers —
  or none where Unicon has never heard its concept, the same judgement the breadcrumb
  makes; only a counter *heading* keeps the fallback circle, being nothing but its
  icon. A counter cache decides how such a tab reads and never whether it is there:
  `8 ZIPs` where the record keeps one — the number read off the record itself, like
  the column, so the tab costs no query — and the bare `ZIPs` where it does not. The
  count is what earns the downcase; a word that leads keeps its capital, like the Show
  and Edit beside it.
- A nested *page* is one of those pages, so it sits in the same card — the *parent*
  record's — with its own tab as the current one and the parent's own Show and
  Edit tabs beside it, each drawn only where its route is, and neither of them marked:
  the nested tab is the page being read. That holds for a nested index and for a member
  page a host nested on purpose — the card
  names the record above, so every template hands it `resource_parent` before its own.
- One tab where a resource has only one of the two pages, rather than no card: the
  card is what says which page of a record is being read, and that is worth saying
  even when there is only one.
- `new` gets no card. There is no record yet, so there is no other page of it to
  offer, and a single `New` tab would name the page it is already on.

## The show page

- It is the edit page with the form taken out. Same `.row`, same
  `mb-3 lg:col-6` per attribute — two columns on a large viewport, one below it —
  and the same title, the record's own label, so a look and a change never
  disagree about what the page is called.
- One rule between rows, so a heading and its value read as one thing and the next
  pair as another. It sits on the cells rather than between them — a column's gutter
  is padding inside it, so two side by side draw one unbroken line — and it is
  `.recourse-values > .recourse-row` that colors it in.
- Every row on *both* pages reserves the width that rule takes, in `transparent`, and
  carries the same `pb-2 mb-3`. That is what leaves a field at exactly the height of
  the value it edits, row after row: the two pages line up to the pixel, so switching
  tabs moves nothing but the controls.
- Which needs two things of the show page's values, both of them about a value being
  as tall as the control that edits it. `.form-control-plaintext` takes a control's
  `min-height`, which Bootstrap defines for it and then never applies; and the reveal
  button loses `.btn-sm`'s, since it is a word beside a value rather than a control
  beside it.
- Each attribute is a heading and a value, not a definition list: a
  `<div class='form-label'>` above a `<div class='form-control-plaintext'>`. The
  first is the class the form's `<label>` wears and the second is Bootstrap's own
  read-only control, whose padding and line height are a control's, so a value sits
  exactly where the input holding it would have.
- A JSON payload is the one value that gets a block of its own: a `<pre>` of
  `JSON.pretty_generate` under `.recourse-payload`, bounded to `12rem` and scrolling
  down. Indented, because that is what makes JSON readable; bounded, because one payload
  is as tall as a page and nothing else on the record's page should move aside for it;
  and wrapping, because a line that runs off to the side takes the layout with it. A
  flex item's automatic minimum size is the min-content width of what is inside it, and
  `overflow` on the box does not lower it — so an unbroken token sets the width of the
  column, then of `main`, and `main` wraps below the sidebar. `white-space: pre-wrap`
  keeps the indentation while allowing the wrap, and `overflow-wrap: anywhere` is what
  lowers min-content; `break-word` looks the same and does not. An empty payload reads
  as the dash every other empty value reads as, rather than as `{}`.
- `.form-control-plaintext` and not a disabled `.form-control`: a box a person
  cannot type in invites them to try. This page has no form on it at all, which is
  the whole difference from the edit page.
- One row per *editable* column, the same list the form offers, so the two pages
  never disagree about which attributes a record has. Encrypted columns included.
- Then `created_at` and `updated_at`, always, at the end and in that order. A
  record's own page is where "when" belongs — however firmly its index keeps the
  two off the table unless `recourse_displayed` asks — and the form never offers
  them, since Rails keeps them. `recourse_displayed` governs the table and this
  page not at all: a show page reads them out for every model, named or not. The shared rows still line up with the edit page;
  the show page is simply two rows longer.
- Each value reads as what it is *of*, not as what it is stored as. A foreign key is
  the label of what it points at, a date is `Aug 12, 2026`, an integer carries its
  delimiters, a decimal is rounded to its own scale, money wears the currency and a
  percentage a `%`, and a phone is punctuated.
- A boolean is a picture: `Unicon[:check]` for true, `Unicon[:close]` for false, and
  `Unicon[:square]` for the one a record never answered. Three states rather than two
  and a dash, because an empty box is a fact about the record and a dash is a fact
  about the page. Each carries an `aria-label`, since an icon says nothing aloud.
- An enum is a `.badge`, in the word the column holds rather than a humanized one —
  the same word the form's menu offers, so the two never read differently.
- Everything else stays the plain link it was. A spreadsheet is a download and there is
  nothing to open in place.
- A **list** takes the same `<details>`, and for the same reason: a column of values
  inside a column of values would push the rest of the page down every time it opened.
  The summary reads how many — `3 items`, `1 item` — since the values are what opening
  it is for, and inside is a `<ul class='mb-0 mt-2'>`. The `mb-0` matters: the row below
  draws the rule between them, and a list's own bottom margin would push that rule away
  from the values it closes.
- Both shapes come from one `detailed(summary, body)` helper. A picture and a list are
  the same markup, and neither should be spelling it out.
- An empty list reads as the dash every other empty value reads as, never as a summary
  with nothing behind it: `listed` answers nil, which is what `resource_value` already
  turns into the dash.
- **A table counts a list rather than drawing one**: the cell reads `3 items` as plain
  text, no `<details>`, and blank where the list is empty like every other empty cell.
  The values belong to the record's own page — a column of values inside a column of
  values is not a table — and the same words serve both, so a cell and a summary never
  disagree about how many there are.
- **A form takes a list one value to a line**, in a `rows='3'` textarea. A newline is
  the one separator a value cannot itself contain, where a comma can sit inside a tag.
  The field is handed its value rather than left to read the attribute, which would
  print the Array's brackets, and `ListResolution` splits the lines back into values on
  the way in — the same seam a typed reference is looked up at, so no host model needs
  a virtual attribute and no host needs a strong parameter of its own. Blank lines are
  dropped: pressing return is not a value.
- Which columns those are is `Recourse.list_column?`, a type that wraps a subtype — a
  PostgreSQL array reports one, and so does a `serialize` of an Array — asked that way
  rather than by an adapter's own class, which only exists where that adapter is
  loaded. **An enum answers the same way and is not a list**: Rails wraps the column's
  own type to map the words onto it, so `defined_enums` is ruled out first, and
  `attribute_kind` asks `:enum` before `:list` for the same reason. Miss that and a
  status stops being a word, on the table and on the form both.
- A counter cache is not on the page at all. Rails keeps it, so there is nothing to
  read and nothing to set; the index table is where a count belongs.
- An encrypted value arrives masked: one `*` per character, and a `Show` beside it
  that swaps the plaintext in. The plaintext travels in a
  `data-reveal-plain-value` attribute and the swap is a Stimulus controller, so
  what a screenshot catches is asterisks and reading one value is a click. See
  CLAUDE.md, "Encrypt PII", for why the page shows PII at all.
- The `Show` is a `<button class='btn btn-link btn-sm p-0 align-baseline'>`, not an
  `<a href='#'>`: it goes nowhere, and a link that goes nowhere is a link that
  breaks when middle-clicked. It removes itself once it has fired, since a reveal
  that has nothing left to reveal reads as though there were more to see.
- The mask and the button sit in the one `.form-control-plaintext`, made
  `d-flex gap-2`, so the pair stays on the line the value would have occupied.
- A value the record has nothing for reads as an em dash, so a heading is never left
  standing over a gap. `false` is something a record says, so only nil and an empty
  list get the dash.

## Forms

- The gem serves `new.html.erb`: it sets `:title` to `New <resource>` and
  renders the `form` partial, passing the record explicitly under its own name.
- It serves `edit.html.erb` the same way, titled after the record instead — the
  value of whatever its model's `recourse_label` names, so a market reads
  `Chicago`. Both render the *same* `form` partial, so a host that writes one
  `_fields.html.erb` gets it on both pages and never writes a second.
- After a rejected update the title shows what was typed, not what is stored,
  because the record already carries the submitted values. Blanking the label
  blanks the title.
- Under a field, where the database has said what its column is for, a `.form-text`
  saying so. A column comment is documentation somebody already wrote — `\d+` shows it,
  and now so does the form — and it is the one question about a column no validator can
  answer, so `recourse_comment` reads it off the schema where every other rule is read
  off the model. A host on an adapter that keeps no comments answers it by hand
  instead; SQLite keeps none, which is why the dummy does exactly that.
- One line under a field, whatever it has to say: a column's comment answers *what
  should I know before I fill this in*, and `field_note` is the one place that decides
  how such a line reads.
- `form-text mt-1 fg-secondary`. `mt-1` because Bootstrap's `.form-text` declares
  `--bs-form-text-margin-top` and then never applies it — `.25rem` is what that variable
  holds, so `mt-1` is the gap the class already meant and not a choice of ours.
  `fg-secondary` for a line answering a question nobody asked: quieter than the value
  above it, and quieter than `.form-text`'s own `--bs-fg-2`, which a color utility
  later in the cascade is what overrides.
- The note carries an id off the field's own — `place_capacity_help` — and the control
  points at it with `aria-describedby`, so it is announced when the field takes focus
  and not only when the form is read straight through.
- Every control the gem draws is told, but each is told a different way, because each
  reaches the browser differently. A text box, a number, a date and a textarea take it
  among the other options `resource_field` builds. A **checkbox** is
  handed it on its own — `kind_field` drops that hash for a boolean on purpose, the
  rest of it being `maxlength`, `pattern`, `placeholder`, `inputmode` and `required`,
  none of which a box that is either ticked or not has any use for. A **combobox**
  carries it as a local, the partial having rendered the attribute for its error
  message all along. A **typed reference** builds the attribute itself, so it says both
  in one place.
- Which field a column gets is decided by what it holds, the same question the show
  page asks: `attribute_kind`. A checkbox for a boolean, a combobox for an enum, a
  number field stepped by what the column keeps, a telephone field for a phone.
- A checkbox goes *under* its label like every other control, not beside it the way
  Bootstrap's own examples put it. The grid is label-above-control throughout, and
  the show page draws the same attribute's icon under the same label.
- A number field says what it will take: `step="1"` for an integer, `step="any"` for
  a float, and for a decimal the scale as the step and the precision as the cap —
  `scale: 2, precision: 4` gives `step="0.01" max="99.99"`. No `min`: how far below
  zero a column may go is the model's business, not the schema's.
- Money and a percentage are attributes whose *type* says so — `Monetary` and
  `Percentage`, registered by the app, reporting `:monetary` and `:percentage` from
  `type_for_attribute`. The gem asks the attribute and never guesses from a name:
  `hourly_rate` is money and `commission_rate` is a share of it.
- Money and a percentage are adorned rather than labelled twice. The wrapper takes
  `.form-control form-adorn d-flex` and the border and padding with it, the unit is a
  `.form-adorn-text`, and the input inside is a `.form-ghost` with neither.
  `.form-adorn-end` reorders the pair, so `%` follows the number and the currency
  precedes it.
- The currency is `number.currency.format.unit` from the locale, never a `$` written
  into a view: an app that counts in euros says so once, where its numbers are
  already formatted.
- The form is `form_with model:` plus one field per *editable* column — every
  column except `id`, `created_at` and `updated_at`. Encrypted columns are
  editable even though the table will not display them.
- Each field is a `.form-label` and a `.form-control` inside
  `.mb-3.lg:col-6`, and the whole set sits in one `.row`. Two fields to a row on
  a large viewport, stacked below it — a name or a phone number needs nowhere
  near the full width of a page, so a form of full-width inputs reads as a
  column of empty space.
- The submit is `btn btn-solid theme-primary`. In v6 the fill is a separate class
  from the base: `.btn` sizes, `.btn-solid` / `.btn-outline` / `.btn-subtle`
  fill, and `theme-*` colors.
- The fill is what tells a link from a button, so it never lies: `.btn-outline`
  is the dress of the navbar's *links* — `Add <resource>`, after the breadcrumb —
  and a real `<button>` that performs, like Create or Delete, is `.btn-solid`.
  A button dressed as a link promises a navigation where there is an action.
- A field whose attribute is not required carries `placeholder='Optional'`.
  Required is judged by the model's validators, not by `null: false` — and a
  `belongs_to` validates the association, so `state_id` counts as required
  through `:state`.
- A required attribute also gets a required *field*: `required` on the input, so
  the browser turns the form back before the server ever sees it. It is the same
  judgement the placeholder makes, from the same validators — the two are
  readings of one fact and never disagree.
- An encrypted attribute's field carries the record's own value in the clear, in
  the field its kind earns — a text box for a surname, an email input for an
  encrypted email. Editing one record is already a deliberate act, so the mask
  stays on the show page, where values are only read. No column name earns a
  password box: a value nobody can read is a value nobody can change, so a masked
  field would either wipe the column on save or need a rule of its own about what
  blank means.
- A required field shows the shape it expects instead: `555-555-5555` for a
  phone, `michael@example.com` for an email. Every other required field has no
  placeholder, since there is nothing useful to show.
- An explicit `type:` picks the sample on its own, required or not. `field :email,
  type: :email` on an optional column shows `michael@example.com` rather than
  `Optional`: the caller has said what the field is, and the sample is the more
  useful of the two hints.
- The field list is a `fields` partial of its own, so a host app can replace the
  fields without rewriting `form_with` or the submit button. It renders one
  `field` per editable column; a host writes the calls it wants by hand.
- `field` takes the column name and two options: `label:` for the heading and
  `type:` for the input, and an explicit type beats every rule below. It is the
  gem's own, not a host's: private for now, and not part of what 4.0 promises.
- The field type otherwise follows the column, and the rules are in this order: a
  foreign key is a combobox; a column named `email` gets an email input; a
  `date` or `datetime` attribute gets its
  own field, the second as `datetime-local`; a `text` attribute gets a textarea
  of a single row — the kind says the value may grow long, not that it starts
  big; everything else follows its kind, encrypted or not.
- A `color` input and a `time` one were here and are not: the dummy app's only
  columns of those kinds went with the market they belonged to, and a branch no
  page reaches is a branch nothing tests. Both are four lines to restore beside a
  column that wants them.
- Length, format and numericality travel to the browser, and all three are read
  from the model's *validators*, never from the column: `maxlength` and
  `minlength` from a length validator's `maximum`, `minimum` or `is`, `pattern`
  from a format validator with `\A` and `\z` stripped since an HTML pattern is
  anchored already, and `inputmode: 'numeric'` from a numericality validator or
  a digits-only pattern.
- A field with a `pattern` also carries a `title` showing the shape it wants:
  `\d{5}` gives `title='Please match the format 00000'`. Without one the browser
  says only that the value does not match, which tells nobody what would. The
  example is read off the pattern — `\d` becomes a digit, `\w` a letter, a bracket
  class its first character, and `{n}` repeats — so the phone's
  `[2-9]\d{2}[2-9]\d{6}` reads as `2002000000`.
- Always pass `size: nil`. Rails mirrors `maxlength` into `size`, and a
  five-character box for a ZIP code undoes the width rule above.
- Which input a `date`, `time` or `datetime` gets is the one thing no validator
  can say, so it comes from `type_for_attribute` — the model's own attribute
  type, which an `attribute` override still governs — and not from
  `columns_hash`.

## Comboboxes for foreign keys

- A form asks for a foreign key one of two ways, and two things decide. Where the
  label has a *length validator* it is short enough to type, so the field asks for
  the value; where the other table is too long to list — `recourse_listable?`,
  100 rows — it asks for the value too, because the alternative is a menu of
  everything. Otherwise it is a combobox to pick from.
- A typed reference names both: the label reads `ZIP code`, not `ZIP`, since a
  code is what the field wants. It takes the shape of that attribute —
  `maxlength`, `minlength`, `pattern`, `title`, `inputmode` — from the model the
  attribute belongs to, but takes *required* from the association that needs it,
  which is the page's model and not the other one's.
- This is what keeps a form from being enormous. `/locations/new` was 3.3 MB when
  its ZIP was a combobox of 40,965 options; typing the code instead makes it
  6.4 KB. A combobox is right for fifty states and wrong for forty thousand ZIPs.
- A value that matches no record leaves the foreign key nil, so `belongs_to`
  reports `Must exist` beside the field, and the field keeps what was typed. That
  value comes from `params`, not from the record — nothing was ever assigned to it.
- `state_id` is still a Bootstrap combobox listing each `State` by `name`, in the
  "Search menu items" form, so a list of fifty stays usable.
- What each option reads is the model's own `recourse_label` — `name` by default,
  `code` for a ZIP, `email` for an Agent. See CLAUDE.md, "Every model says how it
  is labelled".
- The menu holds every row, so it is only as usable as the table is small. The
  ZIP combobox on `/locations/new` is 40,965 options and 3.3 MB of HTML: the
  search box finds one instantly, but the page pays for all of them up front.
  Bootstrap filters what is already in the DOM, so there is no cheaper option
  short of a server-side search.
- The markup is the toggle followed by its `.menu` **sibling** — the plugin finds
  the menu with `SelectorEngine.next`, so anything between them breaks it:

      <button class='form-control combobox-toggle' type='button' id='county_state_id'
              data-bs-toggle='combobox' data-bs-name='county[state_id]'
              data-bs-placeholder='Select a State…' data-bs-search='true'>
        <span class='combobox-value'>Select a State…</span>
        <i class='bi bi-chevron-down combobox-caret'></i>
      </button>
      <div class='menu'>
        <div class='combobox-search'>
          <input type='text' class='form-control combobox-search-input'
                 placeholder='Search…' autocomplete='off' aria-label='Search…'>
        </div>
        <button class='menu-item' type='button' data-bs-value='1'>Alabama</button>
        <div class='combobox-no-results d-none'>No results found</div>
      </div>

- Every combobox logs `Bootstrap doesn't allow more than one instance per
  element. Bound instance: bs.combobox.` to the console, in red, once per render
  and again on every `turbo:morph`. It is upstream's, not ours, and nothing here
  can stop it: `Combobox`'s constructor sets `this._toggle = this._element` and
  then builds a `Menu` on that same element, so Bootstrap's own registry refuses
  the second key and logs. Creating the menu first only moves the complaint to
  the other key; dropping `data-bs-toggle='combobox'` would break the click that
  opens it and not silence anything, since the constructor is what trips it.
- Nothing is broken by it, which is why we live with it: `Menu.clearMenus` reads
  a `static` set of open instances rather than the registry, so an outside click
  and Escape still close the menu, and `Combobox` holds its own reference and
  disposes it. The one casualty is `Menu.getInstance(toggle)`, which nothing
  asks for. Unfixed as of 6.0.0-alpha1 — `js/src/combobox.ts:104` and `:207` on
  `v6-dev` — so a later drop is what fixes it.
- `data-bs-name` is what makes it a form control: the plugin inserts a hidden
  input of that name before the toggle and writes the chosen `data-bs-value`
  into it. Never put `name=` on the toggle itself.
- That input is a node the server never renders, which Turbo's DOM surgery
  knows nothing about — a morphing refresh deletes it while the plugin instance
  keeps writing to the detached node, and a snapshot restore resurrects an old
  one beside the input a fresh instance makes, so a click would submit a filter
  that is stale, doubled or missing. The toggle therefore carries
  `data-controller='combobox'`, whose lifecycle keeps input and instance one
  thing: `connect` removes any restored stale inputs and adopts the instance,
  `disconnect` disposes it (which takes its input with it), and a `turbo:morph`
  disposes and remakes it whole — the constructor reads the `.selected` items
  the morph just made truthful, so one move resyncs the input, the toggle's
  text and the listeners.
- `data-bs-search='true'` enables filtering, but the search input has to be in
  the markup — the plugin only wires up a `.combobox-search-input` it finds.
- That input carries an X inside its right edge once there is anything to clear,
  and nothing before then. A menu of fifty states filtered down to one is two
  keystrokes from being useful again, and a backspace-until-empty is a poor way
  to ask:

      <div class='combobox-search' data-controller='clear'>
        <input type='text' class='form-control combobox-search-input' placeholder='Search…'
               autocomplete='off' aria-label='Search…'
               data-clear-target='input' data-action='input->clear#toggle'>
        <button type='button' class='combobox-search-clear d-none' aria-label='Clear search'
                data-clear-target='button' data-action='clear#clear'>
          <i class='bi bi-x-lg'></i>
        </button>
      </div>

- The button starts `d-none` and the `clear` controller shows it on `input`,
  since whether a field has anything in it is not something the server can know:
  the menu is cached, and the same markup is served to a field being typed into
  and one that was never touched.
- Emptying the field is not enough on its own. Bootstrap filters the menu's rows
  on the field's `input` event, so the controller dispatches one after clearing,
  or the rows stay filtered to a term that is no longer there. It then puts the
  caret back in the field, which is where someone who cleared a search is about
  to type.
- The X is positioned rather than laid out: `.combobox-search` is the relative
  container, the input reserves room with `padding-inline-end`, and the button
  sits in it. A flex row instead would put the button *beside* the field, which
  is a different control — Bootstrap's own search box has nothing there.
- Its `display` is set through `.combobox-search-clear:not(.d-none)`, never on
  the element itself. v6's display utilities carry no `!important` — `.d-none` is
  a plain `display:none` — so any rule of ours with the same specificity and a
  later position beats it, and a `display: flex` on the button showed an X over
  every empty field. Anything the gem styles that a class is meant to hide needs
  the same treatment.
- The toggle carries the `id` the label points at, which is legal because a
  `<button>` is a labelable element. Use `form.field_id` and `form.field_name`
  rather than spelling either out.
- Bootstrap's example uses an inline SVG caret; ours is
  `<i class='bi bi-chevron-down combobox-caret'></i>`. The class only needs
  `flex-shrink` and a rotation, the icon font is already loaded, and the `<i>`
  form is what every other icon on the page uses.
- The placeholder doubles as the empty label: `Select a <Model>…`, from
  `model_name.human` so a registered acronym survives. An optional association
  says `Optional` instead, like any other optional field.
- A required association carries `aria-required` on the toggle rather than
  `required`. The toggle is a `<button>`, which `required` does not apply to, and
  the hidden input that would take it is not in the markup — the plugin writes it
  at runtime. So the requirement is announced, not enforced: the model's
  validation is still what rejects a blank.

## Flash messages

- A flash is a Toast, never an inline alert, in a
  `.toast-container.position-fixed.bottom-0.end-0.p-3` at the end of `<body>`.
  `.toast-container` is `position: absolute` in v6, so `position-fixed` is not
  optional — without it the toast scrolls away with the page.
- The container carries `data-turbo-temporary`: a toast born visible would
  otherwise replay from the page snapshot on every Back, announcing a save that
  happened a page ago.
- The variant is the flash key: `toast theme-success` for a notice, `toast
  theme-danger` for an alert, and a neutral `theme-primary` for a key a host
  invents. The theme goes on the `.toast` itself.
- The message goes in the *header*, and the body is kept but hidden:

      <div class='toast fade show theme-success' role='alert' aria-live='assertive' aria-atomic='true'
           data-controller='toast'
           data-action='mouseenter->toast#stopTimer mouseleave->toast#startTimer focusin->toast#stopTimer focusout->toast#startTimer'>
        <div class='toast-header border-0'>
          <span class='me-auto'>Contact was created.</span>
          <button type='button' class='btn-close' data-bs-dismiss='toast' aria-label='Close'></button>
        </div>
        <div class='toast-body d-none'></div>
      </div>

- That is what tints the whole toast. `.toast-header` takes its background from
  `--bs-theme-bg-subtle` while `.toast` itself takes the plain body background, so
  a message in the body would sit on white below a colored strip. With the body
  hidden the toast *is* the header, and the theme colors all of it.
- `border-0` removes the header's `border-block-end`, which would otherwise rule a
  line under the message with nothing beneath it.
- `me-auto` on the message is what pushes the X to the right. Inside a header the
  close button needs nothing else: v6 gives it margins through
  `.toast-header .btn-close`, which a headerless toast would have had to supply
  itself.
- It autohides after two seconds, but not through the Toast default: the `toast`
  Stimulus controller owns the timer (see below), and hovering or focusing the
  toast holds it open — Bootstrap's own pause-on-hover only guards the timer *it*
  armed, so the controller's actions redo it.
- The wording names the model, never the record: `Contact was created.` and
  `Contact could not be created.`, both from `model_name.human`. Interpolating the
  record instead prints `#<Contact:0x000000012b6febc8>`, because Active Record
  leaves `to_s` as Object's.
- The server ships every toast `fade show`, so *appearing* needs no JavaScript at
  all: the toast paints with the page instead of waiting for the bundle to load
  and run. Bootstrap's `show()` must never run on one — it re-adds `showing` and
  blinks the toast through transparent — and it is also the only place Bootstrap
  arms its autohide, which is why the `toast` controller keeps `autohide: false`
  and runs its own two-second timer. That number is `DELAY` in `written.js` rather
  than the controller's own, because the square that keeps a row runs the same one
  with no toast to keep time with. Only the *hiding* is Bootstrap's, so the
  timer and the dismiss X share one code path and one fade.
- The exit is slower than the entrance it no longer has: the layout stretches
  `--bs-transition-fade` to one second on `.toast`, so the toast fades away
  rather than vanishing. Reduced-motion still wins — the vendored CSS sets
  `transition: none` outright under the media query, which no custom-property
  override can defeat.
- The row a write landed on is marked for exactly as long as the toast says so. The
  server names it in a reserved flash key, `Recourse::WRITTEN`, and `_flash` renders
  it as `data-written-row-value` on the container rather than as a message — the loop
  reads `flash.to_hash.except(Recourse::WRITTEN)`, because every other key there
  becomes a toast of its own, whoever invented it. `FlashHash` has no `except`, hence
  the `to_hash`.
- It rides on the *container* rather than on a toast: that exists once per page,
  `hidden.bs.toast` bubbles up to it from whichever toast hides, and
  `data-turbo-temporary` already takes the whole thing away on a Back — so a mark
  never replays from a snapshot any more than the message does.
- The `written` controller marks the row and lets go on `hide.bs.toast`, so there is
  one clock rather than two: hold the toast open by reading it and the mark holds too.
  `hide`, never `hidden` — Bootstrap fires the first as the toast begins to fade and
  the second only once it has finished, which is a mark still lit a second after the
  message it belongs to has gone. It
  marks nothing where the row is not on this page — written records land on pages that
  are sorted, filtered or paged past them — and nothing where no toast is present,
  since then nothing would ever end it.
- **Every row carries a name**: `<tr id='place_4'>`, from `Recourse.row_id`, which is
  `dom_id`. The name is deterministic per row, so it caches exactly as safely as the
  rest of the fragment.
- The mark is a tint on the cells, exactly like the kept tint beside it: the table
  collapses its borders, so the cells are what paint, and one tint across all of them is
  what reads as a single row. Anything drawn per cell — a border, a shadow — reads as a
  box around each cell instead, which is what a first attempt at this got wrong.
- A background and never a border. A border on a collapsing table is a width the table
  measures around, and taking it away again leaves the line it drew standing between
  two rows that no longer want one.
- `color-mix(in srgb, var(--bs-success-fg) 12%, var(--bs-bg-body))` — the kept tint's
  own formula with one token swapped. Never `--bs-success-bg-subtle`: that resolves to
  `light-dark(--bs-green-100, --bs-green-900)`, and a palette builds those steps by
  mixing toward white or black rather than toward the page, so how far the tint lands
  from the page becomes the palette's business rather than ours. Mixing into the page
  keeps it the same distance on all nine, which is the reason the kept tint is built
  that way and the reason neither `-bg-subtle` token is used for either.
- The success family rather than the primary one, and that is the whole of what tells
  the two tints apart on a row that is both kept and just written. A different hue
  reads as a different thing; a second shade of the primary would read as more of the
  same.
- Fading is an animation on a second class, and the first comes *off* as the second
  goes on. Left on, it would paint the tint straight back the moment the animation
  ended; off, what paints the row afterwards is whatever else the cascade says — a kept
  row's own tint, or nothing.
- `data-bs-dismiss='toast'` still needs the component loaded, so the X is dead
  without the bundle — a `modulepreload` in the head is what has it in flight at
  first paint instead of discovered at the end of the body.

## Validation errors

- A rejected `create` redraws the same page with `422`, never a redirect, so the
  fields keep what was typed and the errors sit beside them.
- The control that failed gains `is-invalid`, and the message follows it as
  `<small class='invalid-feedback'>`. Both are needed: Bootstrap reveals the
  feedback with `.is-invalid ~ .invalid-feedback`, so a feedback element on its
  own stays hidden and an `is-invalid` on its own only reddens the border.
- Because that selector is a *sibling* one, the feedback goes after the whole
  control — for a combobox, after the `.menu`, not inside the toggle.
- Nothing writes that markup by hand. `config.action_view.field_error_proc` does
  it for every field a form builder draws — see CLAUDE.md, "Match Bootstrap with
  field_error_proc".
- The combobox is the exception, because it is a partial rather than a form
  builder tag, so `field_error_proc` never sees it. It adds its own `is-invalid`
  and its own `.invalid-feedback`.
- The message is the bare reason, sentence-cased: `Must exist`, `Can't be blank`.
  The label above it already names the attribute, so a full message would repeat
  it.
- A `belongs_to` reports its error on the association, so a field for `state_id`
  asks the record about both `state_id` and `state` — otherwise a missing state
  reddens nothing.
- An error outranks a hint. A field with both a message and a note under it describes
  the message alone: the note is still drawn, and nothing points at it. Said in the gem
  rather than left to chance — `field_error_proc` is the host's and writes an
  `aria-describedby` of its own for every invalid field, so a second one from here
  would be a duplicate attribute that a browser silently throws one half of. The gem
  withholds its id instead, which makes the rule true for the combobox and the typed
  reference too, neither of which that proc ever sees.

## Tables

- A `<table>` defaults to the hoverable accent, not the striped one:
  `class='table table-hover'`. Reach for `.table-striped` only when a specific
  table is better served by it.
- Always add `.sm:table-stacked`, so rows become stacked blocks once the
  container gets narrow.
- Cells live in a `_row` partial, one `column` call each, with the content in a
  block:

      <%= column header: 'Phone' do %>
        <%= number_to_phone contact.phone %>
      <% end %>

- `column` also takes anything `tag` does — `class:`, `style:` — and passes it
  to both the `th` and the `td`.
- A foreign-key column shows what the record it points at is called, not the id
  that points at it: `/locations` heads a column `ZIP code` and fills it with
  `00501`. The heading is the one the form uses for the same column, so a table
  and its form never disagree about what a column is.
- Those names cost one query per association rather than one per row, because the
  index eager-loads every `belongs_to` the table can name. Twenty locations still
  cost five queries.
- Ahead of those, a table whose model keeps bookmarks opens with the square that
  keeps one: `bi-bookmark` where whoever is looking has not kept the row and
  `bi-bookmark-fill` where they have — Unicon's `:bookmark` and `:bookmarked`, two
  concepts rather than one icon in two dresses, since the hollow one is the deed and
  the filled one the state. Whether this row is one of mine comes before what to do
  with it, which is why it leads.
- It is a `button_to` and not a link, since neither writing nor dropping the row is
  a GET, wearing `btn btn-sm btn-link p-0 border-0 lh-1` — chromeless, because the
  icon is the whole control and a bordered button in every row of a `.recourse-actions`
  square would read as a toolbar. Both states are one path with the verb reversed,
  so the square toggles by flipping the `_method` Rails already wrote into the form.
- It carries `aria-pressed`, which is what says it is a toggle rather than a button
  that does something once, and an `aria-label` reading `Bookmark` or `Remove
  bookmark` to match the state it is in.
- The bookmark square carries **no** tooltip, and the line is drawn on whether the
  thing labels itself rather than on how often it is drawn — a counter's cells carry one per row.
  A bookmark square looks like what it means, filled or hollow, so a label chasing
  the cursor down a column of them is noise; a bare figure looks like nothing at all
  once its heading has scrolled away. The heading above the squares keeps its
  tooltip like any other.
- Its form's CSRF token comes from the `<meta>` tag in the head, not from the token
  `button_to` wrote. Rails scopes a form's own token to the method it was drawn
  with, and this square flips that method; the form is inside a cached fragment
  besides, which makes its token whichever session drew the table. The one in the
  head is global to the session and rendered fresh per request, and Rails accepts
  whichever of the two is valid.
- **No `data-turbo-confirm`, and this is the one exception to the rule above.** A
  delete stays off a table because it cannot be undone; a bookmark is undone by
  clicking the same square again, so a dialog would cost more than the mistake — and
  costs a whole page load more, since this square answers without one.
- The row is tinted as well as squared: a kept `<tr>` wears `recourse-kept`, which
  paints its cells a twelfth of `--bs-primary-fg` mixed into `--bs-bg-body`, so the
  tint follows every palette and both modes without naming a color. Twenty rows are
  scanned by it long before anybody reads a column of icons, and the square is still
  what says the same thing to a reader who cannot see a tint.
- Mixed into the *page*, not taken from the ramp. `--bs-primary-bg-subtle` is a fixed
  step, which on a low-contrast palette lands far enough from the page to cost the
  text a point of contrast it has not got — Solarized's dark mode is the one that
  proves it. Mixing into the page holds the tint the same distance from it whatever
  the palette is.
- A `background-color`, deliberately, and not `.table-active`. That class sets the
  very variable `.table-hover` sets — 10% of the row's own text color against
  hover's 7.5%, the same grey twice — so a kept row would read as the row under the
  cursor and would lose its tint the moment it became one. A background sits under
  the hover shadow instead, so a kept row hovers like any other.
- Not `theme-primary` on the `<tr>` either, tempting as it looks: that sets
  `--bs-theme-*` for everything inside the row, and `.btn-link` and `.badge` both
  read those before their own defaults. The tint would have recolored every button
  and badge in the row with it.
- The click does not wait for the server. The `bookmark` Stimulus controller flips
  the icon, posts in the background and never renders the response, so the table is
  not redrawn and the row keeps its place until the next real page load — which is
  where the kept-first order belongs, rather than yanking a row to the top of the
  table under the cursor that just clicked it.
- **The tint is the report, and it waits for the server.** The icon flips on the
  click; the row takes color only once the write comes back. So the confirmation
  lands where the click happened rather than in a corner of the page, and a click
  that never reached the server never colors anything. Dropping a kept row reads the
  same way round: the tint stays until the delete is actually written.
- Nothing more than the tint. The mark a create or an update leaves on its row would
  land on top of a tint that has just changed, saying a second time what the first
  already said.
- Which is why a click that *worked* says nothing at all. There is no success toast —
  the row is the message, and a toast per click on a column built for clicking twenty
  times would be twenty toasts. Only a failure speaks: the square goes back and the
  error goes in the danger theme, the same markup `_flash` ships from
  `/recourse/flash.js`, carrying `data-controller='toast'` so the timer and the X are
  the ones every other toast uses.
- The no-JavaScript path still speaks, and must: it is a real form submit, so it
  redirects, and a page that reloaded with no word on it would leave a reader guessing.
  `BookmarksController#answer` sets `Bookmark added` or `Bookmark removed` for that
  path and `head :no_content` for the background one.
- The one word it may say travels on the button as `data-bookmark-error-value`: a
  `.js` file has no `t`, so the wording goes with it. One word and one attribute,
  since the other two the square used to carry were the success toast's.
- A table that has actions opens with one column per action, and `_table` adds
  them rather than `_row`. That is the whole point of putting them there: a host
  that writes its own row still gets the columns, prepended before whatever
  columns that row defines, so `/contacts` reads `(eye) | (pencil) | ZIPs count |
  Name | Phone | Created at`.
- One column for the show page and one for the edit page, each drawn only where
  its action is routed. The heading and every cell are the icon rather than the
  word — `<i class='bi bi-eye'></i>` and `<i class='bi bi-pencil-square'></i>` —
  `action_header` answering the icon on the header pass and the action's word on
  every other, so each `data-cell` labels itself `Show` or `Edit`. The heading's
  icon carries `role='img'` and an `aria-label`, and each cell's link an
  `aria-label`, since an icon alone says nothing to a screen reader.
- A look before a change, in the order the seven actions are drawn. Never the
  other way round: the pencil is the one that matters, and putting it under the
  cursor first is how a row gets edited by accident.
- Every icon heading — the two actions and each counter — carries a Bootstrap
  tooltip on top saying what the icon is: `Show`, `Edit`, or the counted model's
  plural, the same word its `aria-label` already speaks. The title travels in
  `data-bs-title` and the `tooltip` Stimulus controller is what makes it,
  since Bootstrap never wires one on its own — and its `disconnect` disposes it,
  so a table Turbo redraws never strands a tooltip over an element that left.
- A resource missing an action gets no column for it, rather than a heading over
  an empty column on every row; a resource with neither opens at its first
  attribute.
- Each is a square: `.recourse-actions` asks for a width of
  `calc(1em * var(--bs-body-line-height) + 2 * var(--bs-table-cell-padding-y))`,
  which is exactly what a single-line cell stands tall — line box plus the two
  vertical paddings, with `box-sizing: border-box` making the two measures the
  same kind. The icon sits centred in it, and a table laying out to 100% hands
  what these cells do not use to the columns carrying text.
- `.recourse-counter` shares that rule, so a counter column starts at the same
  square — but a table treats the width as a preference, never crushing content
  into it, so a figure like `38,405` widens its column to be read whole, and so do
  the words a wide table adds to it; `white-space: nowrap` is what keeps it one line
  while it does. The class comes
  from `counter_class(name)`, which `_row` passes on every column and which
  answers only for a counter.
- Neither rule applies while the table is stacked, where every cell is a block
  and a square one is a squashed one — the `@container` query matches
  `.sm:table-stacked`'s.
- Not while the table is stacked, where every cell is a block and 1% of the row is
  a squashed one. The rule sits in a `@container (width >= 576px)`, which is
  `.sm:table-stacked`'s own query read the other way round, against the
  `.table-responsive` the table already sits in.
- The record arrives under its own name, `contact:` for contacts, so a host
  partial declares `<%# locals: (contact:) -%>`. It is rendered once for the
  header row with that local set to nil, so never assume it is present outside
  a `column` block.
- A host app overrides one table by defining
  `app/views/<resources>/_row.html.erb`, which wins through the controller's
  template prefixes — so keep everything cell-shaped in that partial and
  nothing else.
- Stacking needs two more things, or it degrades badly. The table must sit
  inside a `.table-responsive` wrapper, which is the container query's
  container. And every `<td>` needs `data-cell='<heading>'` — that is where the
  labels in the stacked layout come from, so without it a narrow screen shows
  values with nothing naming them.
- A table of records shows every attribute that is not encrypted, one column
  each. Encrypted attributes are omitted entirely: showing ciphertext helps
  nobody, and decrypting it into a list leaks it.
- A `json` or `jsonb` column is omitted for a different reason and just as firmly. A
  payload is a service's answer kept whole — machinery, not something the row is
  about — and it has no width a column can hold: one of them fills a page, and a
  column of twenty is a table nobody can read. It is the type that decides, asked
  through `type_for_attribute` like every other kind, so `json` and `jsonb` both go
  and an `attribute` override counts. The record's own page still reads it out, the
  way it reads out ciphertext.
- That is a default, not a law, and `recourse_displayed` is the one hook that
  overrules any of them: `def recourse_displayed = :phone`, and it is the host that
  answers for its own screens — a contact recognised by nothing but its number is
  the case this was built for. Read *that* one twice before writing it: the reason
  for the default is what a screenshot of a page of twenty carries. The same hook
  names back the primary key, the inheritance column and
  the two timestamps, none of which carry that risk — so keep the warning attached
  to the columns it is about rather than to the hook.
- The primary key is omitted too. An id is how a row is addressed, not something
  to read about it, and a column of them is a column of noise next to the name
  the row is actually known by.
- `attr_readonly` is not consulted, and deliberately: it says what Rails may write,
  which is not the same question as what a page should draw. A column written once
  is often exactly what a reader wants — a FIPS code, a slug, an external id — and
  a model that would rather no screen drew one says `recourse_hidden :fips`, which
  takes it off the table, the form and the show page together. That the two so
  often coincide is why the gem read the wrong one for a while: a form offering a
  column Rails refuses to write raised on every save.
- It comes out of the search box with the column. A search that matched a column
  no page draws would answer with rows carrying nothing that explains why they are
  there, and the mark that usually explains it has nowhere to go. A host that
  wants one searched anyway names the predicate itself, in `search_field`.
- `created_at` and `updated_at` are shown only where a model names them in
  `recourse_displayed`, and close what the row says when it does — only a counter
  cache is read after them — in that order however the schema declares them or the
  model names them. Neither by default: a timestamp is a fact about the row's
  storage rather than about the thing it stores, and on reference data written by a
  migration it repeats one instant three thousand times.
- They are one of two families with a position of their own — counter caches are
  the other, and are what sits past them. Everything else `recourse_displayed` names
  back keeps the place the schema gave it; these two are lifted out of it and
  appended. That is two terms in `resource_columns`, and one of them reads as
  redundant until a migration adds a column after the timestamps — which is why the
  index test asserts the headings whole rather than asserting their presence.
- A model asks for the one that means something. A booking and a contact show
  `created_at`, since when the work came in and when someone first reached the app
  are part of what those rows say; a setting and an app show `updated_at`, since
  both are written once and edited after — they are what Rails maintains rather
  than what the record is about, and a reader scanning a table wants its subject
  first.
- Column headings come from `human_attribute_name`, so a host app can rename
  one by translating the attribute.
- Counter caches close the row, past even the timestamps: a count says nothing
  about the row itself, only how much hangs off it, so it is read after everything
  the row is. It is a link like the action columns and shaped like one, but it is
  not one of them — a reader reaches the record's own columns first and only then
  what the record gathered.
- A counter cache is headed with the icon of what it counts — the same icon the
  sidebar and the breadcrumb draw for that resource, so the three agree without
  anyone naming it three times. The icon carries `role='img'` and an `aria-label`
  of the counted model's plural — `ZIPs`, not `ZIPs count` — which is also what
  every `data-cell` under it says. Under it the cells hold the figure alone —
  `38,405`, no icon, delimited like the filter-menu counts beside the table.
- That is the narrow reading of a counter, and a table wide enough reads it in
  words instead: the heading says `ZIPs` where the icon was, and each cell says
  `38,405 ZIPs` where the bare figure was. Both are always in the markup and the
  stylesheet picks, since only CSS knows how wide the table came out.
  `.recourse-counter-icon` and `.recourse-counter-word` are the two, the word
  hidden by default and the pair swapping at `@container (width >= 1280px)` —
  Bootstrap's `xl`, read against the `.table-responsive` the table sits in, which
  is the table's width and not the window's: a sidebar takes a few hundred pixels
  the window knows nothing about. The square width above is a preference a table
  never crushes content into, so the column just widens to take the words.
- The word is the counted model's own, through `Recourse.model_title` with both of
  its options: `count:` for `1 place` against `3 places`, and `lower:` for a word
  that follows a figure rather than opening a line — which is also what keeps
  `8 ZIPs` from becoming `8 zips`. The space in front of it belongs to the word
  rather than sitting between the two — and each form carries its own figure, so
  hiding one hides the whole of it.
- Each cell says what it counts twice over besides, without drawing anything: a
  tooltip reading the counted model's plural, for the row where the heading has
  scrolled off the top, and an `aria-label` reading `38,405 ZIPs`, because a link
  whose whole text is a number announces as `38,405` and no more. The tooltip takes
  the word alone, the label takes both, and that is the order somebody hearing it
  needs them in. An unlinked count is a `<span>` carrying the same pair, so a
  counter with no index behind it is named like one that has.
- Neither tooltip needs a rule of its own to know when to keep quiet, because both
  ride on an element the stylesheet is already hiding. The heading's is on the icon.
  The cell's is on `.recourse-counter-figure`, the bare figure — so at `xl`, where
  the figure gives way to `38,405 ZIPs`, there is nothing left to hover and the
  tooltip says nothing a cell reading its own word has already said.
- Which is why the cell writes the count out **twice**: `38,405` in
  `.recourse-counter-figure` and `38,405 ZIPs` in `.recourse-counter-word`, each a
  whole thing to show or hide, rather than a figure with a suffix hung off it. The
  figure appearing in the markup twice is what buys a breakpoint JavaScript never
  has to learn — the stylesheet already owns it. Only one is ever displayed, so
  nothing is read out twice either.
- Every other numeric cell reads the way the show page reads it, through the one
  `formatted_number` ladder Formats keeps: integers delimited, money as
  currency, percentages and decimals at their column's own precision. Only text
  cells are search-highlighted — a search never looked through a number.
- A value that is one absolute web address and nothing else — `WEB_URL` says
  which — is a link to itself on the table and the show page alike: Bootstrap's
  `icon-link` in its `icon-link-hover` style, ending in Unicon's `arrow_right`,
  so the arrow takes a step under the cursor and the value reads as somewhere to
  go. Words around an address, or two addresses, stay text.
- What such a link *reads* is the host, never the address: no protocol, no leading
  `www.`, no trailing slash where the address stops at the host, and `/…` where a
  path follows. A column has room for a host and not for fifty characters of
  identifier, and the href carries the whole of it either way — so the same two
  captures of `WEB_URL` that decide whether a value is a link decide what it says.
- The arrow rides clear of the baseline: bootstrap-icons drops every glyph
  `-.125em` to sit on a text line, so the layout lifts `.icon-link > .bi::before`
  to `.0625em` — clear of the line without floating, and on the `::before`,
  never on the `.bi` box, whose transform is the hover step's to write.
- Column headings that can be sorted are links, which the section below covers.

## Sorting, searching and filtering

- A heading that can be sorted is drawn with `sort_header(name)` in place of a
  bare title, inside the usual `column` call:

      <%= column header: sort_header('name') do %>
        <%= resource_cell record, 'name' %>
      <% end %>

  It draws a link only on the header pass — `@recourse_headers` — and the plain
  title on every other, which is what keeps a `<td>`'s `data-cell` readable text
  rather than a serialized `<a>`; `column` reads the same value for the `<th>`
  and for every `<td>`.
- It is named apart from Ransack's `sort_link`, which it calls. Taking that name
  would take the helper itself away from every view these controllers render,
  since ours would answer first — so a host writing `sort_link @q, :name, 'Name'`
  in a partial of its own still gets Ransack's, unchanged.
- The link passes `hide_indicator: true` and draws its own caret instead —
  `bi bi-caret-up-fill` ascending, `bi bi-caret-down-fill` descending — with no
  caret at all on a column nobody sorted by, so an arrow never claims an order
  that is not in force.
- It also passes `page: nil`, so clicking a heading restarts the table at its
  first page. Ransack's own link already carries every other `q` parameter, so
  sorting keeps whatever search or filter was in force.
- `search_form` renders `recourses/_search`, or nothing where the model's
  `search_field` is nil. A model with filters but nothing to search gets no form
  at all: a row of menus with no box to type into is not a search, and the page
  reads cleaner without it. The index puts it in `content_for :search`
  and never draws it in place, so where it appears is the layout's decision and
  not the table's. It is contributed outside the empty-table branch, so a filter
  that matched nothing can still be cleared from the page it emptied.
- The form is a GET `search_form_for` in a `.recourse-search` row: `d-flex`,
  `align-items-center`, `justify-content-end`, `gap-2`, `ms-auto`, and
  `flex-wrap md:flex-nowrap`. One line from 768px up, since it shares the navbar
  with a breadcrumb and a row that wrapped there would push the navbar's height
  around as a page gained a filter — and free to wrap below that, where a line of
  three filters and a search box has nowhere left to shrink to.
- It takes the width the breadcrumb and the buttons leave, up to `48rem`, and
  gives it back as the viewport narrows. The search box is what absorbs the
  difference — `flex: 2 1 16rem` with an `8rem` floor, against `flex: 0 1 10rem`
  for a combobox toggle — so the field someone types into is the widest thing in
  the row on a large viewport, and the filters keep their labels readable rather
  than growing into space nobody reads.
- That toggle rule is not decoration. `.combobox-toggle` is `width: 100%`, which
  for a flex item means the width of the whole form, so without a basis of its own
  every filter would fight the search box for the entire row.
- Wrapped, the form carries `mt-2 md:mt-0`: the navbar wraps it onto a line of its
  own under the breadcrumb and the buttons, and Bootstrap's flex container has no
  row gap, so the two rows would otherwise touch.
- Below 768px every control in it is `flex: 1 1 100%` and the form's `max-width`
  comes off, so each filter and the search box is a full-width row of its own.
  Once they are stacked there is no second control beside them to share a line
  with, and a half-width box in a column of them reads as unfinished. Both rules are in the layout's
  `<style>`, since neither is a width Bootstrap has a utility for. It
  carries the table's current sort as a `hidden_field_tag 'q[s]'`, without which
  searching would silently reorder the table back to the model's own default.
- The search box is a Bootstrap 6 adorned control: an icon and an input inside
  one bordered box, rather than two elements butted against each other:

      <div class='form-control form-control-sm form-adorn d-flex w-auto'>
        <span class='form-adorn-icon'><i class='bi bi-search'></i></span>
        <%= form.search_field field, class: 'form-ghost', placeholder: prompt,
                                     aria: { label: prompt } %>
      </div>

- Filters reuse "Comboboxes for foreign keys" with `multiple: true`, one per
  `filter_fields` entry whose predicate names a `belongs_to` or an enum. A multiple
  menu item ends with its own check, shown only once picked:

      <button class='menu-item selected' type='button' data-bs-value='1' aria-selected='true'>
        Alabama<i class='bi bi-check menu-item-check'></i>
      </button>

  Where the model a filter lists counts the rows being filtered, each option ends
  with that count: a `<span class='recourse-count fg-2'>` at the right of the row, in
  muted text, so the name reads first and the number answers "how many of these?".
  It stays in the menu: the name goes in a `.menu-item-content > span`, which is the
  one thing the plugin copies into the closed box, so a box showing one chosen option
  reads `Beverly Hills` and not `Beverly Hills4`. That wrapper is `flex: 1`, which is
  also what puts the count at the right without a margin of its own. The tick keeps
  its width while hidden, so ticking an option moves nothing.
- A counted menu is ordered by that count, descending, and by name where two options
  hold the same number. A menu is read from the top and most requests want the option
  most rows are behind; the name is what keeps two equal ones from swapping places
  between requests. Without a count to read, the order is the name alone.
- An option counting none of the rows is `d-none` rather than absent: the markup is
  there and the `All …` line reveals it, which is one more thing that line does
  besides unticking. `.d-none` and not a class of ours, since Bootstrap's utilities
  come last in its stylesheet and win over `.menu-item`'s own display without needing
  `!important` — and the plugin's search sets `style.display` rather than a class, so
  the two never fight. An option already ticked keeps its place in the menu.
  An enum's filter is the same menu over the words the column admits rather than over
  records: headed by the attribute — `Status`, not `Booking status` — since the row it
  sits in names other tables and this one names the table already being read. Its
  reset line reads `All statuses`, the column's own name pluralized.
  Bootstrap only reveals that check for `.selected > .menu-item-check`, so the
  class and the icon travel together. `data-bs-multiple='true'` on the toggle
  is what tells the plugin to write '2 selected' into it, instead of
  replacing the toggle's text with whatever was picked last.
- A multiple menu opens with `All <resources>` above a `.menu-divider` — `All
  states`, `All sources` — which is the filter's own empty state named, and the
  way back to it without unticking whatever was ticked. It is always there, so
  the menu never changes shape as it is used.
- Two things about that entry are load-bearing. It carries no `data-bs-value`,
  which is exactly what Bootstrap's click handler matches on
  (`.menu-item[data-bs-value]`), so the plugin passes it by and the click is
  ours. And it never carries `.selected`, which the plugin counts on *any*
  element in the menu — a checked-looking `All states` would be submitted as
  `undefined` alongside the real values.
- Clicking it clicks each selected option in turn, rather than emptying the
  hidden input by hand. The plugin has no method for this, and driving its own
  path is what keeps the hidden input, the toggle's text and its events its
  business. The submits that follow are coalesced to one, or emptying a filter of
  four would ask the server for four tables.
- A model whose searchable columns are all encrypted gets a search box that asks
  for a whole value: `/agents` searches `email_eq` and prompts `Filter by exact
  email`, where `/states` searches `code_or_fips_or_name_cont`. A `cont` would be
  matching a LIKE against ciphertext and finding nothing, every time.
- Only deterministic encryption qualifies. Without it a value encrypts differently
  on every write, so even `eq` would never match — and that is a model's decision,
  not something a page can work around.
- A foreign key is offered a filter only while the model it points at is short
  enough to list — `recourse_listable?`, which is 100 rows. A menu is a control
  while every row fits in one and a page of HTML nobody reads past that: fifty
  states are a list, 3,144 counties and 40,965 ZIPs are not. Naming that
  predicate in `filter_fields` with a `scope:` draws a filter anyway, over
  whatever narrower relation the scope names.
- Dropping the county menu took `/zips` from 496KB to 22KB. That page was the
  combobox.
- No foreign key's heading is a sort link, whichever control narrows it. Its cell
  shows a label from another table and the id underneath is not the order that
  label reads in: `/locations` sorted by `zip_id` is ZIP codes in the order the
  ZIPs happened to be created, and `/counties` sorted by `state_id` is states in
  the order they were seeded. A heading that claims to sort by what it shows has
  to sort by what it shows.
- What that foreign key gets instead is a place in the search box, its label
  ORed in with the model's own columns: `/locations` searches `zip_code_cont`,
  `/zips` searches `code_or_county_name_cont`. One control replaces the other, so
  a page never loses the ability to narrow by a ZIP or a county — it types the
  word instead of picking it. The label only has to be a word for this: a `cont`
  against an id or a date matches nothing, so a long table labelled by one is
  left with neither control.
- A form asks the same two questions of the same foreign key, and either one is
  enough to make it a typed field: the label is short enough to type, or the table
  is too long to list. A county name has no length to bound it and 3,144 rows
  behind it, and the second question is what keeps a form from drawing every one
  of them.
- The combobox fragment is keyed `[recourses, multiple, selected]`, not just
  the relation: the same relation drawn as a single form combobox and as a
  multiple filter is different markup, and the same menu with a different
  selection is too.
- The table fragment is `cache_if params[:q].blank?, recourses`, so a sorted
  or filtered table is always drawn live rather than cached. Two requests can
  build the identical relation and still want different headings — only one
  of them clicked a heading to get it — so caching on the relation alone
  would serve one request's headings to the other.
- Typing in the search box submits the form after 300ms of quiet, through the
  `search` Stimulus controller registered beside `phone` in the layout:
  `data-action='input->search#submit'`.
- The caret goes back into that box when a submit replaced the whole page, which
  with the results frame in place means only when Turbo is absent. The controller
  cannot
  hold that intent itself — it is torn down with the page it belongs to — so a
  variable in the *module* records it, which the visit does not reload, and the
  next controller consumes it in `connect`. It skips a cached preview, since the
  real render connects again afterwards and is the one that can be typed into.
- Only the caret is restored, not the value: the field is a `search_form_for`
  field, so the server rendered what was typed back into it. `preventScroll`
  keeps a refocus from jumping a long page back up to the form.
- Ticking or unticking an option in a filter submits immediately, with no
  debounce: a filter is one decision, and the table should answer it. A combobox
  writes its hidden input from JavaScript and fires no native `change`, so the
  controller listens for Bootstrap's own `change.bs.combobox`, which bubbles —
  one listener on the form hears every menu inside it.
- What the answer replaces is the table and nothing else. `index.html.erb` wraps
  it in `<turbo-frame id='results' data-turbo-action='advance'>` and the form
  carries `data-turbo-frame='results'`, so a menu stays open while it is picked
  from and the caret stays in the search box, while `advance` still puts the
  query in the address bar for a reload or a shared link to answer.
- The frame wraps *both* branches of the empty check, the table and the
  `none` partial alike. A search that matches nothing has to answer with the
  frame it was asked for, or Turbo replaces the table with an error about the
  frame it could not find.
- What a search matched is marked in the cell that matched it, with `<mark>`,
  through `search_highlight`. A table of twenty rows that all matched says
  nothing about *why* each one did; the mark is the answer, and it is why a
  search and a filter read differently on the same page.
- Only what the search looked through is marked: the model's own searchable
  columns, and the label behind a foreign key the search reaches through, so
  `/locations` marks the ZIP code it matched. Marking a word in a column nobody
  searched would claim a match that never happened.
- `mark { padding: 0 }` in the layout. Bootstrap gives `<mark>` padding of its
  own, which pushes the matched letters apart from the rest of the word —
  `Nash` in `Nashville` reads as a word standing on its own rather than as the
  start of one.
- A marked table is never cached, which the caching rule below already ensures:
  a fragment keyed on the relation alone would serve one search's marks to
  another's rows.
- A link inside that frame navigates that frame, and only two kinds should: a
  heading, which sorts it, and a pagination link, which pages it. Both answer with
  a page that has the frame in it.
- Every other link in a table leaves it, and a page it leaves for has no frame of
  that name — Turbo replaces the table with `Content missing` rather than going
  there. So a link in a cell carries `data-turbo-frame='_top'`, and
  `turbo_link_to` is what puts it there: the edit pencil goes through it, and a
  host's own row partial should too rather than reaching for `link_to`.
- It is worth being able to check. On `/contacts` the frame holds one link, the
  pencil, and it is `_top`; on `/counties` it holds nine, three sorts and six
  pages, and none of them are.
- A heading clicked inside the frame changes the order without redrawing the
  form, so the form's hidden `q[s]` is stale from that moment. The controller
  reads it back off the address bar on `turbo:frame-load` — which is why the
  field is rendered even when nothing is sorted, and why that listener is on
  `document` rather than on the form, whose subtree the frame is not in.
- None of this is required for the page to work. Without Turbo the form is an
  ordinary GET that reloads everything, which is also when the caret has to be
  put back by hand.

## Live index refreshes

- When the host runs turbo-rails, an index page subscribes to its model's
  refreshes: `refresh_subscription` renders a `turbo_stream_from` on the plural
  stream every committed change broadcasts on, so a record saved in one browser
  redraws the table in every other one that has the page open.
- The subscription tag sits *outside* the `results` frame, so a search
  keystroke's frame navigation never tears the cable connection down and reopens
  it.
- The helper also asks the head for two metas, `turbo-refresh-method: morph` and
  `turbo-refresh-scroll: preserve`. Neither is Turbo's default, and without them
  a refresh replaces the whole body and scrolls back to the top.
- A refresh re-fetches the *current* URL, so the search, sort and page params
  the frame's `advance` put in the address bar all survive it.
- The search form sits a morph out: a morph would write the fetched page's older
  query over what is mid-typing, so the search controller cancels
  `turbo:before-morph-element` for anything in the form's subtree, keeping the
  text, the caret and any open filter menu. Never with `data-turbo-permanent`,
  which spans page visits too — every index names this form alike, so a sidebar
  click would carry the last resource's form, filters, and `action` into the
  next page's navbar.
- When turbo-rails is present the layout serves its bundle at
  `/recourse/turbo.min.js` instead of loading plain Turbo from the CDN — the
  same Turbo, plus the `<turbo-cable-stream-source>` element and Action Cable
  client that turn the subscription tag into a connection, in the version the
  host's own gem signed the streams for. Without turbo-rails nothing changes:
  no tag, no metas, the CDN script as before.
- Which models take part is the model's own business — `recourse_broadcasts?`,
  documented in the README — and the helper renders nothing for one that opted
  out.

## Links

- Internal links go through Turbo, so navigation is a fetch and a swap rather
  than a full page load. The layout loads Turbo from the CDN, or from the host's
  own turbo-rails when it is there — see "Live index refreshes".
- Turbo prefetches a link on `mouseenter`, so a page is already on its way
  before the click lands. This is on by default in Turbo 8 — never add
  `<meta name='turbo-prefetch' content='true'>` to restate it.
- Do not put `data-turbo='false'` or `data-turbo-prefetch='false'` on an
  internal link. Either one opts that link out of both behaviours.

## Phone numbers

- A phone number shown to a user always goes through `number_to_phone`, so
  `5552234567` reads as `555-223-4567`. Never print the stored digits raw.
- Storage is unaffected: the column still holds ten bare digits, as `CLAUDE.md`
  requires. The formatting is for reading only.
- In a generic table this keys off the column being named `phone`, which is
  safe because that convention guarantees the name.
- A phone *field* separates as it is typed, not only once it is stored. Every
  `<input type='phone'>` carries the Stimulus controller that does it:

      data-controller='phone'
      data-action='keydown->phone#down input->phone#input'

- The controller formats on `connect` too, so a form redrawn after a rejected
  `create` shows the separators rather than the ten digits it was sent.
- Because the value now carries separators, the `pattern` has to accept them or
  the browser refuses to submit what it just helped type. A phone's pattern is
  therefore `[2-9]\d{2}-[2-9]\d{2}-\d{4}` — the separated form of the model's
  `NORTH_AMERICAN_PHONES`, keeping the rule that an area or exchange code cannot
  start with 0 or 1. The server sees bare digits regardless, since `Phonable`
  normalizes them away.
- Never put a length validator on a phone. `maxlength` would come from it and cut
  the value off at ten characters, three short of `555-555-5555`.
- The `title` says `Please match the format 555-555-5555`, matching the
  placeholder. Where a field has a canonical sample the title uses it rather than
  a shape derived from the pattern, so the two never disagree.

## Times and dates

- A time on a page reads `%b %-d at %I:%M%P %Z` — `Aug 4 at 07:16pm EDT` —
  wrapped in a `<time>` tag carrying the machine-readable value:

      <time datetime='2026-08-04T19:16:51-04:00'>Aug 4 at 07:16pm EDT</time>

- Rails' `time_tag` builds both halves: `time_tag value, l(value, format:
  :recourse)`. Pass the text explicitly — left to itself the helper picks a format
  of its own.
- The `datetime` attribute is `rfc3339`, so it carries seconds and the offset.
  The visible text drops both; the attribute is what a machine reads.
- Zone comes from `Time.zone`, so `%Z` reads `EDT`, `PDT` or `JST` — never `UTC`,
  and never a zone the reader is not in.
- Which zone that is belongs to the reader. `timezone_controller.js` reports
  `Intl.DateTimeFormat().resolvedOptions().timeZone` into a cookie, and
  `Recourse::Zoning` wraps every action in `Time.use_zone` of it, so the *server*
  renders in the reader's zone — the page, the table and the field that edits one,
  all from one place.
- Never localize a timestamp in the browser instead. Rewriting `<time>` with
  `Intl.DateTimeFormat` leaves the form behind, so a reader would read `9:30 AM
  PDT` on a record's page and find `12:30 PM` in the box that edits it. Moving the
  zone rather than the text is what keeps the two pages saying one thing.
- The host's setting is never written. `Time.use_zone` takes a block and restores
  the old zone in an `ensure`, and `Time.zone` is per-thread state rather than
  config — so a host's own screens are drawn against `config.time_zone` as before,
  in the same process and the same second. A cookie naming a zone
  `ActiveSupport::TimeZone[]` does not know is nil, and `Time.zone = nil` falls
  back to that setting too, so a forged cookie changes nothing.
- Storage stays UTC. Never touch `config.active_record.default_timezone` — the
  database keeps UTC and Rails converts on the way in and out, which is the whole
  reason the zone can be a per-request decision at all.
- A table's fragment key carries `Time.zone.name` for the same reason it carries
  the viewer's bookmarks: without it the first reader to load one would settle what
  hour every other reader saw.
- A date with no time of its own reads `Aug 12, 2026`, never `2026-08-12`. The
  ISO form is a value rather than something a reader takes in at a glance, and it
  already has a place on the page:

      <time datetime='2026-08-12'>Aug 12, 2026</time>

- The same `time_tag` draws it, so a date carries its machine-readable form the
  way a time does. `time_tag` writes `iso8601` for a Date and `xmlschema` for a
  time, which is why the attribute is the plain date here and the full offset
  above.
- Both formats live in the locale file, as `date.formats.recourse` and
  `time.formats.recourse`, and one `l(value, format: :recourse)` reads either:
  I18n picks the date format or the time one by what it was handed. So nothing in
  the code asks which it has, a `DateTime` — which is a Date *and* carries a time
  — keeps its time, and a host can show `12 Aug 2026` by writing one key.
- Namespaced under `recourse` rather than written to `default`, or the gem would
  be reformatting every date in the host app that mounted it.
- A locale with no `recourse` format raises rather than degrading: `l` looks its
  format up with `raise: true`, unlike `t`. A host translating these pages
  translates those two keys as well, or turns `i18n.fallbacks` on.
- A *datetime* also says how far off it is, in a tooltip: `3 minutes ago`,
  `in 9 years`. Only a datetime — a date is a day and a time is a time of day, and
  neither is a moment for a distance to count against.
- That one is placed `left`, not `top` like every other tooltip here. The icons that
  take `top` head a column and have the page's chrome above them; a timestamp has
  another row of the table above it, or another value of the same record, and either
  is something a reader may be reading this one against. Bootstrap's `AttachmentMap`
  resolves `left` through `isRTL()`, so it is the reading-order side rather than a
  hard direction.
- The server writes those words with Rails'
  `distance_of_time_in_words_to_now`, which says how far and never which way, so
  the direction comes from the `ago` and `from_now` keys. Those two are worded the
  way `Intl.RelativeTimeFormat` words them — `in 9 years`, not `9 years from now` —
  because the browser says the same phrase again a moment later, and two spellings
  of one phrase read as two. The server's is what a reader without JavaScript gets.
- The browser says them again on the way to the tooltip, through
  `Intl.RelativeTimeFormat`. It has to: a table is cached and a page is left open,
  so words rendered on the server are only true at the moment they are drawn —
  `3 minutes ago` would still read `3 minutes ago` tomorrow. Bootstrap reads a
  tooltip's words once when it makes one, so the refresh goes through
  `setContent` on `mouseenter`, registered before the `tooltip` controller beside
  it makes the instance.

## Pagination

- Paginate with the `pagy` gem, never hand-rolled offsets.
- Two page sizes and no more, named once in `Recourse::LIMITS`: 20, which is
  pagy's own default and what every table opens at, and 100 for a reader
  scanning rather than reading. `index` passes the one in force as `limit:`.
- Which of the two is the reader's own, kept in their browser under
  `Recourse::LIMIT_STORAGE` — a *cookie*, not local storage, which is where the
  scheme goes. Pagy decides the page on the server, and a cookie is the only
  storage the server is sent, so every index answers to it with no `?limit=` in
  any address and nothing written to the host's database.
- `Recourse::Paging#recourse_limit` checks that cookie against `LIMITS` and falls
  back to 20. Never skip that check: a cookie is a value a stranger can write, and
  an unchecked one is `?limit=100000` by another route.
- Which is also why `max_limit` stays unset. Without it pagy ignores a `?limit=`
  in the query string outright, so the only way to ask for a page size is the one
  we check.
- Below the table, in this order: the count, then — only while `pagy.last > 1` — a
  `&middot;` and the switch after it, then `series_nav :bootstrap` at the right for
  the links. `series_nav` needs `<%==` rather than `<%=`, since it returns HTML. A
  table that fits on one page is not being paginated, so it says how many items it
  has and offers neither the dot nor the switch.
- The switch names the size it is **not** showing: at twenty to a page it reads
  `100 per page`, and having been clicked it reads `20 per page`. The sentence
  beside it already says how much of the table is on the page, so what is left for
  a control to say is where a click goes, not where the reader is.
- It is a `<button>` wearing `.btn-link`, never an `<a>`: it performs something
  rather than leading anywhere, and there is no address to give it — the query
  string is not asked for a page size. `p-0 align-baseline` and a `min-height: 0`
  of its own keep it a word in the sentence rather than a control beside one.
- Which size a click writes is worked out on the server and handed over as
  `data-limit-to-value`, so the page and the cookie can only ever disagree if one
  of them is forged — and the read is checked anyway.
