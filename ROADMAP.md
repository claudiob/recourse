# Roadmap

What is known to be wrong and what is planned to change, with the evidence for each.
Written 2026-08-27 from a survey of every app on `recourse_4` — autopilot, fountain,
goldrush, houston, pizza — and a full trace of the gem's own visibility and feature code.

Nothing here is implemented. `CHANGELOG.md` is what shipped.

## What 4.0.0 left in drive

Version 4.0.0 ships what goldrush and houston use and nothing else. What was built in
`drive` and cut on the way here, each a feature a later minor release may bring back:
Active Storage attachments; cloning a record; tables arranged by drag; a table read as a
map; a resource with no rows of its own; a listing that edits a join (`through:`); a
parent named through a polymorphic key; singular resources (`recourse`); the three
generators; the eight color palettes; `recourse_extra_columns`, `_actions` and `_tabs`;
a combobox narrowed by another; and the `values:` shape of a `filter_fields` entry.
Fountain and autopilot use several of those and do not run on 4.0.0.

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
