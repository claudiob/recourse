# Roadmap

What is known to be wrong and what is planned to change, with the evidence for each.
Written 2026-08-27 from a survey of every app on `recourse_4` — autopilot, fountain,
goldrush, houston, pizza — and a full trace of the gem's own visibility and feature code.

Nothing here is implemented. `CHANGELOG.md` is what shipped.

---

## Known defects

Each was verified in code this session. File and line are where to start.

### A hidden column is still queryable

`Searchable#ransackable_attributes` (`lib/recourse/searchable.rb:20-22`) filters on
encryption alone. It never consults `Recourse.hidden_columns`, so
`?q[webhook_url_cont]=hooks` reaches a column the model asked to keep off every screen.
"Hidden" currently means hidden from rendering, not from querying. Whether that matters
is a threat-model question, but the gap is not documented anywhere and is certainly not
what a host writing `recourse_hidden` expects.

### `recourse_displayed` silently outranks `recourse_hidden`

`Helpers::Cells#hidden_columns` (`lib/recourse/helpers/cells.rb:28`) subtracts
`recourse_displayed` from the flattened whole of `columns_hidden_by_default`, which
*includes* `Recourse.hidden_columns`. So a column named in both is hidden everywhere
except the index table.

Two comments say otherwise: `README.md:637` says `recourse_hidden` keeps a column "off
every screen", and `cells.rb:34-35` calls it "the one of these a host decides *without*
the override above". Both are wrong. No dummy model exercises the overlap — `Place` hides
`webhook_url` and displays the timestamps, `Memo` displays `about_type` — so nothing
catches it.

### The show page draws both timestamps unconditionally

`Helpers::Cells#shown_columns` (`cells.rb:62`) appends `TIMESTAMPS & column_names`
regardless of `recourse_displayed`. That matches `STYLE.md:531-533` and contradicts
`README.md:636` and the `recourse_displayed` entry in `CHANGELOG.md`. One of the three has
to give.

### Four `recourse_hidden` entries are the counter bug wearing a disguise

Why a `has_many through:` count is invisible is already written down — `CLAUDE.md`, *A
counter is one only if the inverse belongs_to says so*. What the survey adds is the cost:
`Vertical#plans_count`, `Vertical#departments_count`, `Department#plans_count` and
`Provider#plans_count` are all named in `recourse_hidden` for no reason but that. They are
not visibility intents, and fixing the detection deletes all four.

### A stale declaration is tolerated in silence

fountain's `Nomination#recourse_hidden = :participant_sid` names a column that no longer
exists in its schema. The gem neither warns nor raises. Worth a boot-time check, in the
company of `unsorted_position` and `two_positions`.

---

## The visibility API

### The diagnosis

It is not four surfaces, it is **eight decisions driven by two hooks**: index table, show
page, form fields, *strong params* (a separate decision from the form — they already
disagree by the parent foreign key), search box, sort headings, filter menus, and
attachments.

`recourse_hidden` removes from all eight — `CLAUDE.md`, *recourse_hidden has no table-only
form*, is the rule and the warning. `recourse_displayed` adds back to exactly two, the
index and the show page. Nothing addresses the other six.

What that rule does not say is why it is so expensive, which is the coupling underneath:

| List | Jobs it does |
| --- | --- |
| `Recourse.editable_columns` | form fields · **strong params** · the show page's base · the clone list · the seed generator |
| `Recourse.hidden_columns` | four screens · search · sort · filters · the attachment list · the seed generator's required-gate |

Nine call sites for the second. So hiding a column from a table silently changes what the
search box looks through, whether a heading sorts, which filter menus appear, and which
file fields a form offers. None of that is stated anywhere, and none of it is what "hide
this column from the table" means to the person writing it.

Two smaller ones: `recourse_hidden` doubles as an *attachment* hider
(`recourse_hidden :photos`), so one namespace holds two kinds of thing; and the primary
key is spelled `primary_key` on the index and hardcoded `'id'` everywhere else.

### What the apps actually declare

33 `recourse_hidden` declarations across five apps, 13 `recourse_displayed`. Classified by
the surface each author's own comment names:

| Stated intent | Count | Expressible today? |
| --- | --- | --- |
| Off the **form** ("nobody's to type", "never moves") | 11 | only by losing index and show too |
| Off the **index** only ("would be read by scrolling") | 12 | **no** — becomes a `_row` partial |
| Off the **search box**, index as collateral | 6 | partly |
| Wanted **nowhere** (dead columns) | 8 | yes — the one case the hook fits |
| Not a visibility intent at all (the counter bug above) | 4 | — |

All 13 `recourse_displayed` declarations mean **index**; five also mean show; one wants a
column on show but *not* index and cannot say so. **None wants the form. None wants the
search box.**

### What the gap costs today

**12 of 30 host `_row` overrides exist purely to shorten an index** that `recourse_hidden`
could not shorten without also emptying the form.

fountain's `Provider` is the extreme: 18 of the 21 columns its controller re-permits are
in `recourse_hidden`, so one index-width decision costs a `resource_params` override plus
two hand-written form templates that bypass `_fields` entirely.

Two host comments state the problem outright. autopilot's `DepartmentsController`:
*"Hidden is the gem's one word for both."* And fountain's `Location::Recoursive` is a
documented refusal —

    # The apartment and the coordinates stay, noisy as they are on a table:
    # `recourse_hidden` is off *every* screen, so hiding them takes the apartment out of
    # the form that enters an address and the latitude off the page that reads an
    # enrichment back.

He wanted them off the index and on the form, could not say it, and left a table he calls
noisy.

### The trap, live in production

**goldrush cannot create five of its models.** `Assessment`, `Conversation`,
`OfferQuestion`, `SatisfactionQuestion` and `SpecialtyMatch` all hide `callback_url`,
which is `t.text null: false` with no default and no callback, and all five are routed
full CRUD. The comment on all five is the same:

    # Columns no admin table shows.
    def recourse_hidden = %i[ callback_url coverage model options ... ]

The author said *table*; the hook emptied the form; `editable_columns` is also the permit
list, so nothing can supply the column. `Conversation` does not even validate it, so it is
a raw `NOT NULL` violation rather than a form error.

autopilot has four of the same shape and none of them fire, because it has removed
`new`/`create` from exactly those resources (`config/routes.rb` lines 22, 36, 56, 79, 85).
Cause or coincidence, that is the pattern.

### The recommendation

**Name the surface, and keep one hook.** `recourse_hidden` takes a hash keyed by surface;
a bare list keeps today's meaning, so nothing breaks:

    def recourse_hidden = { table: %i[callback_url coverage model options] }  # goldrush, fixed
    def recourse_hidden = %i[requested_dates]                                # unchanged, means nowhere

Barely longer than what is written now, it expresses all eight states, and it deletes the
two-hook dance along with the outranking bug above. `recourse_displayed` keeps only its
real job — overriding the *gem's* defaults (encryption, timestamps, JSON, primary key) —
which is a different axis and is what all 13 uses are actually for.

**And refuse loudly.** A per-surface API makes the trap less likely but does not close it.
If a column is off the form, required, has no default and nothing fills it, and `create`
is routed — raise, the way `recourse_order` already raises `unsorted_position` and
`two_positions` rather than guessing. goldrush would have found all five at boot.

### Also worth revisiting

`recourse_extra_columns` has **zero** host uses across all five apps, despite three
autopilot `_values` overrides doing precisely its job. The reason is one line of markup:
`_values.html.erb` appends `host_columns` unconditionally, and each of those three rows
should appear only under a condition. How the hook itself works is in `CLAUDE.md`, *A
derived table draws columns, and only columns*.

---

## Separating the add-ons

The goal is not to ship separate gems. It is to find the seams inside this repo so each
concern can be switched off — after which `recourse-bookmarks` becomes "load it or don't"
rather than a rewrite. Doing it here first means the protocol is designed against real
features with a working suite, and a mistake costs an edit rather than a released gem.

### The two rules that decide the design

**No metaprogramming** rules out every registry that resolves names, and `CLAUDE.md`
closes the door explicitly: "never treat the places above as permission to add another —
ask instead."

**`minimum_coverage 100`** means a feature flag is not free: an `if Recourse.bookmarks?`
body only counts as covered when the dummy turns it *on*, so a boolean per feature would
make the dummy carry both states of every flag.

### The mechanism

`Recourse.features` is an array of **modules**, never names. Core calls literally-named
methods on them: `feature.draw_routes mapper` is a plain call, and `include one` with a
variable module is Ruby's own API. Neither is metaprogramming, and the gem already leans
on the view-side half of this idiom four times — `respond_to?` plus a literal call, in
`helpers/buttons.rb:49`, `cards.rb:26`, `values.rb:12` and `sidebars.rb:13`.

Two levels of switch, and the second mostly exists already:

- **Per install** — is the module registered. Later: is the gem in the Gemfile.
- **Per app** — did the host declare anything. `Recourse.bookmarks = nil` is off because
  the host *said nothing*. Positioning has the same shape (`:positionable`), joins have it
  (`through:`), attachments have it (`has_many_attached`).

**Clone is the only candidate with no host declaration.** Give it one rather than adding a
boolean — the single behavioural change this asks of an existing feature.

The protocol:

    # What every add-on answers, defaulted to nothing, so one names only its own hooks.
    module Feature
      def draw_routes(mapper) = nil    # routes inside a `recourses` block
      def controller_concerns = []     # mixed into every recoursed controller
      def model_extensions = []        # every Active Record class is extended with these
      def model_inclusions = []        # and included with these
      def helper_modules = []          # view helpers for the pages the gem renders
      def stimulus_controllers = []    # [identifier, served path] pairs
      def leading_columns = []         # names, ordered by Recourse::LEADING_COLUMNS
    end

Three further hooks — `table_digests`, `record_actions`, `form_notes` — belong on the
feature's *helper* module under `respond_to?`, because only the view context reaches `t`,
`url_for` and the record. That reuses the `recourse_extra_*` idiom rather than inventing a
second one.

### Add-on or core

| Add-on | Lines out | | Stays core | Why |
| --- | --- | --- | --- | --- |
| Themes + colors | 1,819 (1,512 CSS) | | Search & filters | an index with no sort, filter or box is not this gem |
| Positioning, write half | ~700, undecided | | Attachments | owns the write path — see the prerequisite |
| Bookmark | 475 | | Counter caches | a column *kind*, read in five files |
| Clone | 361 | | PII masking | its absence is a security regression |
| Zones | 100 | | Pagination | Positioning needs pagy's offset |
| Joins | 97 | | Aggregates | the inverse of a registry |
| Shortcuts | 72 | | Generators | need no hook at all |
| Live refreshes | 60 | | | |

About 3,740 lines out for about 40 lines of machinery in.

Two findings worth keeping. `grep 'position\|bookmark\|clone\|sortable' lib/generators`
returns nothing — the generators know about columns, validations and counters, not
features, and should not grow a hook. And locale needs no machinery: Rails deep-merges
`config.i18n.load_path` across engines, so an add-on ships its own `recourse.en.yml` with
only its keys, and the alphabetical-keys rule becomes *per file*.

### Extension points core must grow

**Routes.** `routes/nested.rb:11-20` names three features in one core method. It becomes
`Recourse.features.each { |feature| feature.draw_routes self }` inside the same `scope`.
Cost: `scopes.rb:12-18` keeps `current_module` and `parent_resource` private, and a
feature needs both plus `addressable_rows?` — three public readers, about 8 lines,
unavoidable.

**Controllers.** `include(*Recourse.features.flat_map(&:controller_concerns))` uses the
same `Module#include` that `base_controller.rb:6` already uses. Whole controllers need
nothing new: `Controllers.define_missing path, base` is the sanctioned exception and
already takes a base class. It only needs documenting as public API.

**Model hooks.** `extend` in four files, `include` in two. That split is Ruby's, not a
flaw: `Recoursive` answers questions about a *class*; `Arranged` registers callbacks and
acts on one *record*. Collapsing them needs `define_method`. Unify the shape instead — one
`on_load :active_record` block replacing five.

**View slots.** The existing `recourse_extra_*` hooks cannot serve the table, for three
reasons all in code: `values.rb:24` escapes markup, so a `button_to` cannot pass;
`_row.html.erb:8-10` draws host columns *after* the resource columns, where a bookmark
square must lead; and there is no CSS class hook for `recourse-actions`. So a new
**leading-column** slot is needed, and the four hard-coded blocks in `_table.html.erb`
collapse to one loop over objects answering `header`, `cell(record)`, `css_class`,
`applies?`. The cheaper slots reuse what exists: the actions area is already a list, the
card tabs are already a list, and the form note is one line.

**Cache-key riders.** `_table.html.erb:14` carries six, three of them features'. It
becomes `[recourses, row_digest, resource_columns, *table_digests]`. The rule already
documented in `helpers/joins.rb:24-30` — each rider leads with its own name, since an
expanded key renders `nil` and `[]` identically — becomes part of the hook's contract. It
is the only thing stopping two features' empty riders from sharing a fragment.

**JavaScript.** A helper emits the import list and the register list from
`stimulus_controllers` pairs, keeping the `if (!window.Stimulus)` guard verbatim.
`engine.rb:34-41` already chains `Rack::Static` with `cascade: true`. One fix: the last
static root does not cascade and so terminates the chain — add-on roots insert before it,
or it gains `cascade: true`.

**Queries.** `search.rb:44` needs the bookmark order term to precede the model's own or it
does nothing, which earns one narrow hook: `def leading_order(model) = []`, specified as
running ahead of the model's order. The `@arranged` veto gets no hook at all.

### Order of work

1. **Bookmarks — the proving ground.** The only candidate touching every hook kind:
   routes, a conjured controller with a custom base, a model question, a leading column
   with icon and class, a cache rider, a Stimulus controller, locale, a query refinement,
   layout CSS. Already has the right off-switch shape.
2. **Joins — the proof, at 97 lines.** Structurally the twin. If it lands using only the
   hooks bookmarks defined, the protocol is right. Learning otherwise here beats learning
   it at 798 lines.
3. **Live refreshes.** Sixty lines, and it exercises what bookmarks does not: a
   `before_action` contribution and an `Aggregate` question.
4. **Themes and colors.** Biggest payload, thinnest coupling. Needs a stylesheet-link slot
   beside the layout-head hook step 1 built.
5. **Positioning — decide here, not before.** See below.
6. **Clone.** Last: no off switch, and spliced into `new` and `create`.

### The open decision: does Positioning move at all?

Only its *write* half is ever in question. `positions.rb` — the model questions and the
`arranged?` veto — stays in core either way. What could leave is `Positioning`,
`PositionsController`, `Arranging`, `Arranged`, `helpers/arrangements.rb`,
`sortable_controller.js` and the 57 KB vendored `sortable.js`: about 700 lines, the
second-largest payload after themes.

**Keeping it buys one thing worth having.** The grip stays hard-coded, so the
leading-column slot only has to carry a bookmark square and a join button — an icon or a
button, a CSS class, a predicate. The grip is by far the most demanding cell in that row,
needing the sortable controller and data attributes for the position and the update URL.
Since the slot is designed in step 1 and everything downstream inherits its shape,
simplifying it is the highest-leverage simplification available. It also shrinks
`LEADING_COLUMNS` to `%i[bookmark join]`.

**It buys nothing else.** Bookmarks still needs every other hook, the veto is already
resolved, and the write-path prerequisite is untouched.

**So defer it.** Steps 1 and 2 need nothing from Positioning. Build the slot for a square,
prove it with a join button, then ask whether it could carry a grip. If it can, extracting
Positioning later is a known quantity; if two simple cells already strain it, the answer is
that Positioning stays whole. The apps genuinely split: autopilot arranges five models,
goldrush's are logs and arrange nothing.

### Prerequisite, before any of it

**Split the write path out of `attachment_writing.rb`.** That concern owns
`create_resource` and `update_resource` (`:14-27`) — the gem's entire write, including the
transaction cloning depends on. A `Recourse::Writing` concern should own `save` and the
transaction, with `AttachmentWriting` contributing only `attach_submitted_files`. This is
a refactor of core, not an extraction, and nothing about attachments can move until it
lands.

### What does not come apart cleanly

This list matters more than the optimistic half. A plan that pretends the seams are clean
is worse than one that names the ugly ones.

- **`arranged?` is a veto, not an addition.** Four core files stand down when it is true:
  `search.rb:81` (no conditions), `searches.rb:28` (no form), `sorts.rb:48` (no sort
  links), `cells.rb:47-49` (column dropped). No addition-shaped hook expresses "this
  feature turns three others off", and a general veto protocol would be larger than the
  feature. Accept it: `Recourse.position_columns` and the `@recourse_position` assign stay
  in core as a question core asks, and about 40 of Positioning's lines never leave.
- **Clone reads `Recourse.position_columns`** (`cloning.rb:24`), which looks like an add-on
  reading a sibling and is not: `positions.rb` stays in core under the point above, while
  only the write half leaves. Clone reads core. There is no cross-gem dependency and no
  hard `require` between them.
- **`Aggregate` gets longer as features leave.** Six of its declarations exist only
  because an optional feature asks. Leave them: they answer nobody when the feature is
  absent, and the file already reads as a list of nothings.
- **Table order must not be a Gemfile decision.** `_table.html.erb:26-34` argues in prose
  for grip, then square, then join, then actions. Registration order would let a Gemfile
  silently reorder every table in every host app. Core keeps `LEADING_COLUMNS` — which
  means core still names its add-ons, a deliberate leak downward and the better of two
  options.
- **`cacheable_table?` carries search's word.** `helpers/rows.rb:31-33` tests
  `params[:q].blank?`. If search ever left, half that predicate goes with it.
- **The protocol is itself permanent coupling.** Seven methods every future add-on is
  written against, which core then cannot change freely. The coupling exists today but is
  invisible; a protocol turns it into a promise.
- **100% coverage is a cost of the gem endgame, not of this step.** Each extracted gem
  needs a dummy of its own, or they all test against this one.

### Sequencing between the two

`recourse_hidden` is read in nine places spanning screens, search, sort, filters and
attachments. **The visibility redesign should land before features start reading it across
a gem boundary**, or the new API ships twice.

### Verifying an extraction

Per step, not at the end.

1. `bundle exec rake` after each feature moves — 100% line coverage, RuboCop clean. Check
   any new file's length by hand before `git add`, since the task reads `git ls-files`.
2. Turn the feature **off** in `test/dummy` and confirm the suite still passes with its
   tests removed. That is the only real proof the seam holds, and turning it back on must
   restore every assertion.
3. Boot each host app on `recourse_4` and confirm the routes still draw. The routes DSL
   runs at boot, so a broken hook fails loudly there rather than on a page.
4. After the bookmark step specifically: confirm a table with nothing kept and a table
   that keeps nothing still draw different fragments. The self-naming rider rule is what
   prevents them sharing one, and it is the easiest thing to get wrong.
