# Coding Guidelines

**Scope:** `~/code/guidelines/STYLE.md` is the authority for code style, and this
repo abides by it. This file carries only what is true of *this* repo and not of
the others — a rule that belongs to every codebase goes upstream instead, and a
rule recorded here that turns out to be general is moved rather than copied.

## Ruby

- Two-space indentation, no tabs. No trailing whitespace; newline at EOF.
- `snake_case` for methods/variables, `CamelCase` for classes/modules,
  `SCREAMING_SNAKE_CASE` for constants.
- Predicate methods end in `?`; mutating/dangerous variants end in `!`.
- `do...end` for multi-line blocks, `{...}` for single-line blocks.
- Guard clauses over nested conditionals. Return early.
- Use `unless` for simple negatives; never `unless ... else`.
- Prefer `&.`, `||=`, `Array()`, `Hash#fetch` with defaults, and keyword
  arguments over positional args once there are more than two.
- Keep methods short and single-purpose. Extract private methods freely.
- Comment *why*, not *what*. Don't narrate the code.

## Rails

- **Follow the Rails Way.** Reach for framework features before writing
  custom infrastructure.
- Fat model / skinny controller. Controllers do routing, authorization,
  params, and rendering — nothing else.
- RESTful routes and the seven standard actions. Prefer nested resources or
  new controllers over custom actions.
- Use strong parameters; never pass raw `params` to a model.
- Scopes for reusable queries; avoid query logic in controllers or views.
- Guard against N+1 with `includes` / `preload` / `eager_load`.
- Validations and DB constraints together — the database is the last line of
  defense (null constraints, unique indexes, foreign keys).
- Migrations are reversible; never edit a migration that has shipped.
- Concerns for genuinely shared behavior, not as a dumping ground.
- Background jobs (Active Job) for anything slow or external.
- Secrets in credentials/ENV — never committed.
- Views: partials and helpers over logic in ERB. No queries in views.
- I18n for user-facing strings.

## Testing

- Never test another library. `validates :name, presence: true` is Rails'
  behavior, already tested in Rails, so a test asserting a blank name is
  invalid tests nothing of ours. Same for a unique index raising, or pagy
  splitting 25 rows across two pages.
- Test our data, our wiring, our own methods: what a backfill contains, what a
  helper returns, what markup a view produces, how many queries a page costs.
- Every behavior change comes with a test.
- Test behavior and public interfaces, not private implementation details.
- Descriptive test names that state the expected outcome.
- Prefer fixtures/factories that are minimal and explicit.
- Keep tests independent and order-agnostic.

## Git

- Small, focused commits. Imperative mood subject lines ("Add", not "Added").
- Explain *why* in the body when the change isn't self-evident.

---

## Learned preferences

Guidance from Claudio, recorded as it comes up. These override the baseline
above when they conflict.

Grouped under what each rule is *for*: performance, security, testing,
maintainability, readability, internationalization. A new rule goes under the
heading it serves, not at the end of the file, and a rule that could sit under
two is filed under the one a reader would look in first.

### PERFORMANCE

#### PostgreSQL, always

- The guidelines' exception for a gem's dummy app is what this one takes, since
  2026-08-14. The database is a file under `test/dummy/storage`, created and
  migrated on the first `rake test`, and deleting `storage/*.sqlite3*` is the
  reset; `dropdb --force` stays the reset for the PostgreSQL apps.
- The rule binds the apps we write — never the gem. The gem's own code names no
  adapter, so a host on any of the three is served the same: column kinds are
  read through `type_for_attribute` and `defined_enums`, which every adapter
  answers, and no adapter's own constants are named at all.
- What PostgreSQL alone offers, the dummy states the portable way: an enum is a
  string column with an `IN` check constraint reading the model's constant, a
  two-letter shape is `GLOB` rather than `~`, backfills say `current_timestamp`
  rather than `now()`, and there is no citext — the dummy's one plaintext email
  is a plain string. The enum and email rules below still bind the apps we write.

#### Clear the cache when a table's structure changes

- Change what the default index table draws — which columns it shows, how a heading
  reads, whether a column sorts, what sits at the end of a row — and clear the
  dummy app's cache in the same breath: `cd test/dummy && bin/rails tmp:cache:clear`.
- The fragment key does not notice. `cache recourses` digests the relation and the
  *template*, and everything above is decided in the gem's Ruby — `resource_columns`,
  `sort_header`, `resource_actions?` — which no digest covers. The page keeps
  serving the table it drew before the change, and the next person to look at it in
  a browser sees a feature that appears not to work.
- Data changes need no such thing: the relation's own version — its count and its
  newest `updated_at` — is part of the key, so a new row expires the fragment by
  itself. It is only the shape of the markup that goes stale.

#### Cache a query or a fragment that repeats

- Reach for `Rails.cache` wherever the same rows would be read or the same markup
  re-rendered. An index table and the option list behind a combobox are both
  cached; `/places/new` reads the rows behind its Team menu on the first request
  and only checks their version on the next, which is the `SELECT` that goes.
- Key a fragment on the *relation*, `cache recourses do`, never on a hand-rolled
  string. Rails builds the key from a digest of the SQL — so a different page of
  the same table is a different key — and pairs it with a version from the row
  count and the newest `updated_at`, so nothing has to remember to expire it.
- The table's key carries four riders:
  `[recourses, row_digest, resource_columns, join_digest, bookmark_digest]`.
  `row_digest` is the digest of whichever `_row` the lookup resolved — `render
  'row'` resolves host-first at render, which the fragment's own template digest
  never follows. `resource_columns` is the column list, decided in Ruby the
  digest cannot see either: a host adding `recourse_hidden`, timestamps or a
  counter expires the table by itself. What still needs the hand-clear is markup
  shape the list does not carry — how a heading reads, what sorts.
- The last two are there for the same reason as each other: both draw buttons whose
  state lives in a table the relation knows nothing about, so the relation's own
  version — its count and newest `updated_at` — does not move when one is clicked.
  `join_digest` is the joined ids, `bookmark_digest` the kept ones. The bookmarks
  are also the *viewer's*, which makes that rider do double duty: it is what expires
  the fragment on a click and what keeps one person's kept rows off another
  person's page. Each leads with its own name, because an expanded key renders
  `nil` and `[]` as the same empty string — without it a table with nothing kept
  and a table that keeps nothing would share one fragment, and whichever drew first
  would decide whether the other had any squares.
- That version check is itself a `SELECT COUNT(*), MAX(updated_at)`, and it is the
  price of never serving a stale menu. Keying on `recourses.cache_key` instead
  skips it and queries nothing at all, at the cost of a list that never notices a
  new row — only worth it behind an `expires_in`, and only for data that may lag.
- The check is free where the relation is already loaded, which is why the index
  costs nothing extra: `blank?` loads it before the table renders, so the version
  is counted in Ruby. Another reason to prefer `blank?` over `empty?`.
- Cache the table, not the pagination around it. The nav changes with the page and
  is cheap to draw.
- A cache that is off in tests is a cache nobody tests. The dummy app sets
  `config.cache_store = :memory_store` for the test environment: caching stays on,
  and the run leaves no files behind.

#### Fewest SQL queries to render a page

- Rendering a page should issue as few queries as it can. Treat an extra query
  as a defect, not a detail.
- When checking whether a relation has records *and then looping over them*, use
  `present?` and `blank?`, never `any?` and `empty?`. `blank?` runs the
  `SELECT "contacts".*` that the loop needs anyway and caches it; `empty?` runs a
  separate `SELECT 1 ... LIMIT 1` first, so the page costs two queries instead of
  one.
- `any?` and `empty?` are still right when nothing will be looped over.
- An index eager-loads every `belongs_to` its table can name, since each cell that
  shows a referenced record would otherwise be a query of its own:
  `resource_class.includes(*names)`. Twenty locations cost five queries rather than
  forty-two, and the count no longer grows with the page.
- Worth a test: assert the query count, so a later edit cannot quietly add one
  back. `TestRecoursesPerformance` does this by subscribing to
  `sql.active_record` through `IntegrationCase#queries_on`, and it is one of the
  two kinds of test exempt from "as few tests as coverage needs".

#### Select only the columns a query displays

- A query built to display something fetches those columns and no others.
  The combobox of states shows a name per row and submits an id, so it reads
  `State.select(:id, :name).order(:name)` — not `State.order(:name)`.
- This sits alongside "fewest SQL queries to render a page": the count of
  queries is one cost and the width of each is another.
- It applies where the columns are known. A generic table hands the record to a
  row partial that may touch anything, so it selects everything on purpose.

#### Emails are citext

- A plaintext email column is `citext`, never `string`. An address is
  case-insensitive in practice, so `Ada@example.com` and `ada@example.com` are
  the same one, and the column type is what makes comparison and a unique index
  agree with that.
- citext arrives with its extension, so a migration runs
  `enable_extension 'citext'` before the first citext column is created.
- Nothing else is then needed: no `LOWER(email)` expression index, and no
  downcasing on the way in.
- An *encrypted* email column is not citext — the same reasoning as the rest of
  "Encrypt PII". What is stored is ciphertext, so a case-insensitive column
  compares the wrong bytes and could reject two genuinely different addresses.
  Normalize in Rails instead, always with both options:
  `encrypts :email, deterministic: true, downcase: true`.
- `deterministic: true` is not conditional on the column being unique or
  queried *today*. An address is the natural handle for finding a record, so it
  will be looked up eventually, and switching afterwards means re-encrypting
  every row. `downcase: true` is what earns the case-insensitivity the citext
  column would have given, and it is what keeps a unique index honest: without
  it two spellings of one address encrypt to two different values.

### SECURITY

#### Encrypt PII

- Personal data is stored with Active Record Encryption: `encrypts :phone`,
  `:email`, `:surname`, `:street`. Suspect a column is personal? Ask before
  storing it in the clear.
- `name` is not PII and is not encrypted. A first name on its own does not
  identify anyone; a surname does. Asked and settled — do not encrypt it.
- A column that is queried or must stay unique needs
  `encrypts :phone, deterministic: true`. Non-deterministic ciphertext differs
  every write, which silently defeats both a unique index and a uniqueness
  validation — they will pass while duplicates pile up.
- Never constrain the *shape* of an encrypted value in the database. What is
  stored is ciphertext, so only `null: false` and a unique index still mean
  anything; the format belongs to the model.
- Encrypted columns never appear in a generic *table*, so encrypting a column
  removes it from the index page. That is intended — see `STYLE.md`. A model may
  name one back with `def recourse_displayed = :phone`, which is the host taking
  the screenshot risk on purpose rather than the gem deciding for it.
- A *show* page is the other way round: it draws every encrypted column, because
  this is an admin tool for agents and reading a record's PII is part of the job.
  Encryption settles what the database keeps, not what a page may say.
- Which makes the screen the risk rather than the disk, so the show page masks
  what it shows: one asterisk per character, and a `Show` beside it that swaps
  the plaintext in. A screenshot then discloses nothing nobody asked to see, and
  reading one value is a deliberate click. Markup in `STYLE.md`.
- The *edit* form shows an encrypted value in the clear, in the field its kind
  earns. Editing one record is already a deliberate act, and a value nobody can
  read is a value nobody can change: a masked box would either wipe the column on
  save or need a `leave blank to keep it` rule of its own. Asked and settled — do
  not mask form fields, and no column name earns a password box.

#### Phone numbers

- A phone number is stored in a column named `phone`, holding exactly 10
  digits.
- The database enforces `null: false` and a unique index. It does not check the
  ten-digit shape — a phone is PII, so it is encrypted, and no constraint can
  read ciphertext.
- Rails is where the shape is enforced: the model includes a `Phonable` concern
  carrying both rules:

      NORTH_AMERICAN_PHONES = /\A[2-9]\d{2}[2-9]\d{6}\z/

      normalizes :phone, with: ->(phone) { phone.delete('^0-9').delete_prefix '1' }

      with_options format: { with: NORTH_AMERICAN_PHONES, message: '...' } do
        validates :phone, allow_nil: true
      end

- The concern's validation is `allow_nil`, so whether a phone is *required* is
  the including model's decision — add `presence: true` there, not in the
  concern.

### TESTING

#### As few tests as coverage needs

- The suite exists to cover the code, so a test that can be deleted while
  coverage stays at 100% is a test to delete. Write the smallest set that gets
  there and stop.
- Never add a test for lines the suite already covers, even to reach a *branch*
  it misses. Line coverage is the whole budget.
- Never test a migration. A backfill's row count, the values it wrote and the
  invariants between them are data, and asserting them exercises no code of
  ours. Whole classes have gone this way — the dummy's reference tables each had
  one asserting a row count and a backfill's values, and none of them ran a line
  of the gem.
- A model that only declares validations, associations and encryption is in the
  same position: nothing measured runs, so it gets no test file. The dummy's
  concerns went the same way.
- This narrows the baseline's "every behavior change comes with a test": the
  test comes with it only if it reaches a line nothing else does. The suite it
  leaves is small on purpose — 43 runs for 1,427 lines, across fourteen files, each
  rendering one page and asserting everything true of it.
- Two kinds of assertion are exempt, because a covered line cannot stand in for
  them. How many queries a page costs, and how an encrypted column reaches the
  page — masked on a show page, not at all on an index, in the clear in its own
  kind of field on a form: they run exactly the same lines whether they hold or
  not, so coverage stays green while the behavior breaks. The PII leak that
  prompted the second exemption printed an address at 100%.
- Nothing else is exempt. Markup, titles, breadcrumbs, icons, pagination links
  and the order of the sidebar are all asserted by whichever test happens to
  render the page, and no test is added to pin them down further.

### MAINTAINABILITY

#### No metaprogramming

- Never call `send` or `public_send`. Reach the data directly instead:
  `resource.attributes[column]`, not `resource.public_send column`.
- No `define_method`, `method_missing`, `instance_variable_get` / `_set`,
  `const_set`, `constantize`, or `eval` of any kind.
- The sanctioned exceptions, by name — everything else still needs an explicit
  instruction. `Recourse::Controllers` (`const_defined?`/`const_get`/`const_set`/
  `Class.new`) is the gem's core promise: a routes line conjures a controller.
  `Recourse.model`'s `safe_constantize` is its input step: a route name becomes
  a class or a routes-file error. `ResourceResolution`'s
  `instance_variable_set "@#{name}"` keeps the host-template contract — a host's
  view reads `@contact` the way a hand-written controller would set it.
- Reading an association without `public_send` is a *trade*, not a loophole:
  `record.association(name).reader` (deletions, references) leans on a `:nodoc:`
  Rails API to honor this rule. Keep the trade; never widen it.
- Never reach for metaprogramming on your own initiative, and never treat the
  places above as permission to add another — ask instead.

#### Both sides of an association

- A `belongs_to` gets the matching `has_many` on the other model by default. A
  foreign key is a relationship, and reading it from one side only is half the model.
- `dependent:` follows what the child requires: `:destroy` where the child needs the
  parent, `:nullify` where the association is optional. A `Job` cannot exist without
  its `Location`, so deleting the location takes its jobs with it; a `Message` may
  have no `Job`, so a deleted job leaves its messages standing.
- `:destroy` rather than `:restrict_with_error` on purpose. An admin deleting a
  record is entitled to delete the tree under it, and a `State` reaches a long way
  down — counties, then their ZIPs, then locations, then jobs. The point of the
  cascade is that they do not have to dismantle it by hand.
- That reach is exactly why a delete names what is about to go, and how much of it,
  before it goes. Settled wording, in a `data-turbo-confirm`:

      Delete California?

      58 counties and 3 markets will be deleted with it.
      12 messages will be kept, without a job.
      Anything under those goes too.

      This cannot be undone.

- Counted one level down and no further: one `COUNT` per `has_many`, `:destroy`
  children reading as *deleted with it* and `:nullify` ones as *kept, without a
  parent*. Counting the whole tree means joining 40,965 ZIPs to draw an edit page,
  and `Anything under those goes too` is what stands in for the levels below.
- `has_many` takes one name, unlike `validates`. `has_many :counties, :markets`
  does not declare two associations — it reads `:markets` as a scope and fails much
  later with `undefined method 'arity' for an instance of Symbol`, from a view.
- Neither side helps against `delete_all`, which is raw SQL and skips callbacks. A
  test that clears a parent table still needs the children gone first.

#### An enum is a Postgres type

- An enum column is a native Postgres type, not an integer and not a bare string:
  `create_enum :job_status, Job::STATUSES` and then
  `t.enum :status, enum_type: :job_status, default: :draft, null: false`. The
  database rejects a value the model has never heard of, and the column reads as the
  word rather than as a number nobody can interpret.
- The names live in a `STATUSES` constant on the model, one per line with a comment
  saying what that state means, and the model declares
  `enum :status, STATUSES.index_by(&:itself)`. The migration reads the same constant,
  so the type and the model cannot drift at creation time.
- A list of values is a table of its own. That is the rule for the apps we write and
  it stands: none of them models a list as an array column, which is why the dummy's
  one such column (`media_urls`) went on 2026-08-14 along with the gem's array
  rendering and seeding.
- What changed on 2026-08-26 is the other half. The gem *reads* a list a host already
  has, because hosts have them — houston's `providers.technologies` is a `text[]`, and
  the gem had already been taught to keep one out of a search box before it could
  draw one. A record's page shows it behind a `<details>`, a table counts it as
  `3 items`, and a form takes it one value to a line.
- The dummy carries one for that code to be covered by, and it is a fixture rather
  than a change of mind: `Place#tags`. SQLite has no array column — `array: true` is a
  PostgreSQL-only option and every other adapter raises on it — so it is a `text`
  column with `serialize :tags, type: Array, coder: JSON`, which reports the same
  wrapped type a real `text[]` does. That is the only question the gem asks about
  either, so the fixture is not a stand-in for the behaviour, only for the storage.

#### Trailing comma on a multiline hash or array

- A multiline hash or array ends its last entry with a comma, so adding an entry
  touches one line instead of two:

      NAVIGATION_ICONS = {
        'States' => 'geo', 'ZIPs' => 'geo-alt-fill',
      }.freeze

      STATUSES = [
        :draft, # ... has been written down and nothing more (default)
      ]

- Put the closing brace or bracket on its own line. With it trailing the last entry
  the comma reads as `, }`, which is worse than either alternative — and this is what
  decides how to break a literal that only spans lines because it is long. Give it
  the closing line rather than leaving `,]` at the end of the last entry:

      safe_join [
        @recourse_form.label(column, label, class: 'form-label'),
        resource_field(@recourse_form, column, type: options[:type]),
      ]

- Enforced by `Style/TrailingCommaInHashLiteral` and
  `Style/TrailingCommaInArrayLiteral`, both with
  `EnforcedStyleForMultiline: consistent_comma`. Not `comma` — that style
  *forbids* the comma unless every entry sits on its own line, and ours share
  lines.

#### Keep render lines out of the logs

- An app's log never carries Action View's `Rendering ...` and `Rendered ...`
  lines. One line per partial buries the request that matters — a 20-row table
  rendering a row partial produces 20 of them.
- Set `config.action_view.logger = nil` in `config/application.rb`. Everything
  else stays: the request, the SQL, and the `Completed 200 OK` timing line,
  which still reports view time.
- The page's chrome is not the log's subject either: no `Started GET` for a
  stylesheet, a script or a font, none for `/cable`, and no WebSocket or
  `Turbo::StreamsChannel` chatter.
- The gem's own files go quiet by *placement*: its `Rack::Static` middleware
  sits before `Rails::Rack::Logger`, so a `/recourse/*` fetch is answered before
  the logger ever sees it — which is why the gem may do this for every host
  without touching anyone's logging config.
- The cable goes quiet in the app: `Rails::Rack::SilenceRequest, path: '/cable'`
  — the middleware `silence_healthcheck_path` already uses — inserted before the
  request logger, plus `config.action_cable.logger = ActiveSupport::Logger.new(nil)`,
  which is what swallows `Successfully upgraded` and every
  `Turbo::StreamsChannel is streaming` line. Silencing is per-thread and lifts
  for errors, so a page request alongside stays loud.
- This is a rule for apps we write. The gem never touches a host's logging.

#### Keep RuboCop current

- `AllCops: NewCops: enable`. Cops added by a new RuboCop release are active
  immediately rather than sitting pending; fix what they surface instead of
  pinning the version.
- Enabling every new cop is not the same as accepting every new cop. One can be
  declined outright, in `.rubocop.yml` with the reason beside it.
  `Gemspec/RequireMFA` is: whether a push needs MFA is settled on the RubyGems
  account, not asserted in the gem's own metadata, so the gemspec carries no
  `rubygems_mfa_required` and the cop is off rather than merely satisfied.
- `AllCops: SuggestExtensions: false`. Every run was ending with a nine-line
  advert for `rubocop-minitest` and `rubocop-rake`; we are declining both, not
  postponing them, so the suggestion is off rather than merely ignored.

#### Gemfile ordering and version constraints

- List gems alphabetically, in one block — no blank lines splitting the list,
  since those read as separate groups.
- Never use `~>`. Use `>=` only where a minimum version is genuinely required,
  and otherwise give no constraint at all.
- Every gem carries a trailing comment on the same line saying why it is
  there — what would break without it, not what the gem is.
- The same applies to `add_dependency` in the gemspec.

#### No static typing

- Never write Ruby type signatures, and never add a strong-typing tool.
- No RBS: no `sig/` directory, no `.rbs` files. `bundle gem` creates one —
  delete it.
- No Sorbet: no `# typed:` sigils, no `sig { ... }` blocks, no `T.let` /
  `T.nilable` / `T.must`, no `srb` or `tapioca`.
- Never add these gems: `sorbet`, `sorbet-runtime`, `rbs`, `steep`, `tapioca`.
- Convey intent through clear names, short methods, and tests instead.

#### Ask the validators, not the schema

- What a value is allowed to be is the model's business, so read it from the
  validators. A length validator gives a field its `maxlength` and `minlength`, a
  format validator its `pattern`, a numericality validator its numeric keyboard.
  Never reach into `columns_hash` for a `limit` or for a type.
- The schema and the validators disagree more often than it looks. A `limit: 5`
  column with no length validator accepts four characters; an encrypted column's
  limit describes ciphertext. Following the model keeps the browser saying what
  the server will actually enforce.
- Where no validator can answer — which of `date`, `time` and `datetime` an
  attribute is — ask the model anyway, through `type_for_attribute`. It reports
  what the model declares, so an `attribute :opens_on, :date` override counts,
  and `columns_hash` still never appears.
- Corollary for the database: a constraint the model does not also state is a
  constraint the browser cannot show. Add the validator too.
- A boolean is the exception worth remembering: `null: false` on one earns
  `inclusion: { in: [true, false] }`, never `presence: true`, which rejects
  `false` along with nil. A `limit` is a length only on a string or a text
  column — on an integer it counts bytes, and validating it as a length would
  cap a smallint at two digits.

#### Every model says how it is labelled

- A model answers `recourse_label` with the column a combobox shows for one of its
  records. `Recourse::Recoursive` supplies `:name`, and every Active Record model
  is extended with it through `ActiveSupport.on_load :active_record`, so most
  models need say nothing at all.
- A model whose identity is not a `name` overrides it — `:code` for a ZIP, `:email`
  for an Agent — but never in the model body. It `include`s its own `Recoursive`
  concern, in `app/models/zip/recoursive.rb`, which overrides inside
  `class_methods do`. The default arrives by `extend`, so only a class method can
  replace it.
- The label is what gets selected: `select(:id, label).order(label)`, per "select
  only the columns a query displays". So it has to be a real column, not a method —
  a method would not survive the `SELECT`.
- Reading it back is `recourse.attributes[label]`, not `public_send`, which "no
  metaprogramming" rules out.
- Picking an encrypted column labels the option with its plaintext, since
  `attributes` decrypts. That is a decision to make deliberately, not to fall into,
  and it reaches further than a form: a foreign-key column in a *table* shows the
  same label, so an encrypted one appears on the index of every model that
  references it. `resource_columns` only keeps a model's own encrypted columns out.
- `recourse_typed_label?` asks whether that label has a length validator, which is
  what decides between typing a value and picking from a list. A length is the only
  honest signal available: it says the value is bounded, so a person can type it.
- A typed label is looked up on the way in — `ZIP.find_by code: '90210'` — and the
  form asks for it under the foreign key's own name, so no host model needs a
  virtual attribute and strong parameters need no special case.

#### A derived table draws columns, and only columns

- Learned upgrading Fountain from recourse 3, where sixteen index tables were taken
  off their `_row` partials one at a time. Most of what follows was measured the
  hard way; it is written down so the next host costs less.
- `resource_columns` is `Recourse.ordered(model, column_names - hidden)`. A
  *method* is invisible to it, however much it reads like a column. A booking
  delegating `email` through its location to its contact has no `email` column, so
  no table draws one, and `recourse_displayed` cannot help — that hook un-hides
  real columns, it does not invent them. A `has_one` names no column either.
- So the honest answer to "main's table showed X and this one does not" is often
  that X was never a column. Check the schema before reaching for a hook.


#### The order of a row is banded, and there is no hook for it

- `Recourse.ordered` groups by band — `state`, `reference`, `scalar`, `boolean`,
  `long`, `date`, `timestamp`, `counter` — and `group_by` is stable, so the
  schema's own order stands *inside* a band and nowhere else.
- That leaves exactly three levers, and it is worth saying which: **which** columns,
  through `recourse_hidden` and `recourse_displayed`; **order within a band**,
  through a column-reorder migration; and **order across bands**, which is not
  available at all.
- So an index that showed a status or a foreign key *late* cannot be reproduced: an
  enum is forced to the front of every row and a `belongs_to` to just behind it.
  Keeping a host `_row.html.erb` is the only way to match such a table, and that is
  a fair answer rather than a failure — three of Fountain's sixteen keep one.

#### A counter is one only if the inverse belongs_to says so

- `recourse_counters` reads `association.inverse_of&.counter_cache_column` off each
  `has_many`. A column merely *named* `answers_count` is not a counter: it lands in
  the scalar band, is headed by `human_attribute_name` — "Answers count" rather than
  "Answers" — and draws as a bare number with no icon and no link.
- A column kept up by hand is the usual cause. Fountain increments `answers_count`
  in an `after_create_commit`, so the gem cannot see it; declaring
  `counter_cache:` on the polymorphic `belongs_to` would fix both the counting and
  the heading. An Active Storage attachment count can never be one — there is no
  `belongs_to` to declare it on.
- A recognised counter links only where a nested resource's last path segment
  *equals the association's name*: `nested_path_of` is
  `Recourse.nested_under(path).find { |one| one.split('/').last == association.name.to_s }`.
  A booking's `answers_count` will not link while the page listing those answers is
  nested as `messages`. The count still draws; only the link is withheld.

#### Arranging is opted into by :positionable, not by a direction

- `positionable_key` returns nil unless `recourse_order` is a **Hash**, and
  `arranged?` compares the direction against `POSITIONABLE = :positionable`. So
  `'position ASC'`, `:position` and `{ created_at: :desc }` are all plain orders,
  and only `{ position: :positionable }` arranges.
- Which makes tidying a SQL-string order into a symbol behaviour-neutral, and
  turning one into `{ column: :positionable }` a feature switch: it hands the table
  drag handles and takes the column off it. Never do the second while doing the
  first.

#### Decorate a cell in named_cell, never in reference_cell

- `reference_cell` has two jobs. Besides a table cell it supplies a **form field's
  value**, through `typed_reference_value` — so markup put there is rendered inside
  `<input value="…">`, where a reader sees an anchor tag spelled out.
- `named_cell` is the layer the table and the show page share and the form does
  not, which is the whole reason it exists. Cell behaviour goes there: the link on a
  foreign key was added that way, and the next such thing should be too.

#### A generated controller inherits the gem's own base

- `Controllers.define_missing` is `Class.new(base || RecoursesController)` and every
  caller passes no base. So a host's namespaced base class — an
  `Admin::Providers::RecoursesController` written to set `@provider` — is **never**
  in a generated controller's ancestry, and its `before_action` never runs.
- The failure is quiet and reads as something else: the ivar is nil, and
  `form_with model: [@parent, @record]` collapses to the collection path of a
  resource that may not have one. What surfaces is `undefined method 'things_path'`,
  which names neither the parent nor the controller.
- The lesson is the rule: anything **every** nested screen needs is the gem's to
  supply, not a concern for a host to remember to include. `ParentNaming` exists for
  exactly that reason, and a host writing a controller per nested resource just to
  inherit a base class is a sign something belongs here instead.

#### recourse_hidden has no table-only form

- Stated in STYLE.md already — it takes a column off the table, the form and the
  show page together — and worth repeating here because it is easy to reach for
  while tuning an index and expensive to get wrong. `Recourse.editable_columns`
  subtracts `hidden_columns`, and both the form and `shown_columns` are built from
  that. `recourse_displayed` overrules the gem's *defaults* on a table; it does not
  put a `recourse_hidden` column back on a record's page.
- So a column that is merely noisy on an index has nowhere to go. Hiding
  `locations.apt` took the apartment out of the form that enters an address; hiding
  `lat` and `lng` took the latitude off the page that reads an enrichment back. Two
  tests caught both, which is the argument for having them.
- The one case where hiding costs nothing is a resource routed `index` and `show`
  only: there is no form to lose. Check the routes before hiding, not after.
- What every app on `recourse_4` actually declares, what the gap costs them, and the
  replacement proposed for it are in `ROADMAP.md`. Read that before changing this hook:
  goldrush cannot create five of its models today for exactly this reason.

#### Vendor what a page cannot render without

- A stylesheet or script a page cannot do without is vendored into the gem and
  served from it, never linked to a CDN. A host that fails to reach the CDN gets
  an unstyled page, and the Bootstrap 6 CSS in particular comes from a preview
  host with no promise of staying put.
- The files live in `vendor/recourse/`, and an engine initializer serves them with
  `Rack::Static`. That is the framework's own middleware rather than a controller
  action, and it assumes no asset pipeline, which a host may well not have.
- Keep the slash on the prefix. `urls: %w[/recourse/]` matches on `start_with?`,
  so `urls: %w[/recourse]` would answer `/recourses` with a 404 from the file
  server before the router ever saw it — in this gem of all places.
- Vendor whatever the vendored file itself asks for. `bootstrap-icons.min.css`
  loads `fonts/bootstrap-icons.woff2` relative to itself, so the CSS without the
  fonts renders every icon as a blank box.
- Keep the copies byte-identical to what the CDN serves, so a later version can
  be diffed against upstream. `git ls-files` puts them in the gem already.
- Our own JavaScript is not vendored. It lives in `app/javascript/recourse/` and
  is served at the same prefix: the first `Rack::Static` takes `cascade: true`, so
  a path it has no file for falls through to the second rather than 404ing. That
  keeps `vendor/` meaning "upstream's", which is what exempts it from the lint.
- A Stimulus controller imports Stimulus by its served path, not by the bare
  `@hotwired/stimulus` specifier. Resolving that name would need an import map,
  and a host app may already ship one of its own.
- Start the application in the `<head>`, and guard it with `window.Stimulus`.
  Turbo re-runs body scripts on every visit, and a second application connects
  every controller a second time.

#### Design lives in STYLE.md

- Every decision about how a page looks — Bootstrap conventions, class choices,
  markup structure — is documented in `STYLE.md`, not here. Read that file
  before writing or editing any layout, view or partial.
- This file stays the authority for code style. Where the two overlap, `STYLE.md`
  wins on markup and `CLAUDE.md` wins on Ruby.

### READABILITY

#### Files at most 100 lines

- No code file goes over 100 lines, counting blank and comment lines. When one
  gets close, split it — extract a class, a concern, a partial, a second test
  case.
- Enforced by `rake file_length`, part of the default task. RuboCop has no
  file-length cop; `Metrics/ClassLength` and friends measure a class body, not a
  file, and skip comments and blanks by default.
- `.md`, `.txt`, `.html` and `.erb` are exempt. Prose is not code, and a view
  is markup whose length is driven by the page, not by design choices.
- Anything under `db/migrate/` is exempt. A migration that backfills a table is
  as long as the data it carries, and splitting one to satisfy a line count
  would be worse than leaving it long.
- So is anything under `vendor/`. Upstream's formatting is not ours to fix, and a
  vendored font is not even text — `File.readlines` on a `.woff2` reports
  thousands of lines that mean nothing.
- The task reads `git ls-files`, so an untracked file is invisible to it. A green
  run before `git add` proves nothing about what the commit will contain.

#### Lines at most 100 characters

- Hard limit of 100 characters per line, enforced by RuboCop's
  `Layout/LineLength` (`Max: 100`, up from its default of 120).
- Split long strings across lines with `\` continuations rather than letting a
  line run over.
- Views are exempt — `.html` and `.erb` files may run past 100 characters,
  since a CDN URL or a long class list cannot be wrapped usefully. RuboCop does
  not lint them anyway.
- When a method call would need three lines and hanging indentation just to fit,
  hoist the long arguments into a Rails `with_options` block instead. Still
  three lines, but every line starts at a normal indent:

      with_options format: { with: SOME_PATTERN, message: 'is invalid' } do
        validates :phone, allow_nil: true
      end

#### Shared behavior becomes a concern

- When two models declare the same behavior word for word, extract it into a
  concern instead of leaving the copy in place.
  `encrypts :email, deterministic: true, downcase: true` stood in both `Contact`
  and `Agent`, so it became `Emailable`.
- Name the concern after the feature it carries, not after the models that want
  it: `Emailable`, `Phonable`.
- Only what the models genuinely share moves. `Contact`'s email is optional and
  `Agent`'s is required, so `presence: true` stays in each model — the same line
  `Phonable` already draws for `phone`.
- This sharpens the baseline's "concerns for genuinely shared behavior": a second
  identical declaration is the threshold, and anticipating one is not.

#### As few parentheses as possible

- Omit parentheses on a method call's arguments; keep the inner ones, where
  parsing needs them:

      Object.const_set class_name, Class.new(RecoursesController)

- Enforced by `Style/MethodCallWithArgsParentheses` with
  `EnforcedStyle: omit_parentheses`. The cop is off by default, so it needs
  `Enabled: true` as well as the style.

#### Name non-trivial regular expressions

- A regular expression that is not obvious at a glance gets a named constant,
  so the name explains the intent and the pattern is stated once.
  `/\A[2-9]\d{2}[2-9]\d{6}\z/` becomes `NORTH_AMERICAN_PHONES`.
- Put the constant on the class or module that owns the rule, and comment it
  with what it accepts and rejects — the name says what, the comment says why
  those bounds.
- Trivial patterns used once, like `%r{\Aexe/}`, stay inline.

#### Comment every public declaration

- Never comment a private method. The rule below is for the public surface; a
  private method earns its explanation from its name and its caller.
- Never put a method in a controller that only a view calls, and never reach for
  `helper_method` to expose one. If a view needs it, it belongs in a helper
  module or inline in the template. A controller's private methods are for the
  controller's own work.
- Indent `private` to match its `class` or `module`, not the `def`s under it, so
  it stands out as a divider. Enforced by
  `Layout/AccessModifierIndentation: EnforcedStyle: outdent`.
- Precede every public class, module, constant and method declaration with a
  comment line saying what that object does. This narrows the baseline's
  "comment why, not what" rule: declarations get a *what*, and the *why* rule
  still governs comments inside method bodies.
- Say what it is for, not what the code plainly shows. `# Raised for every
  failure the gem reports` earns its place; `# The Error class` does not.
- A module reopened purely as a namespace in another file is not redeclared —
  document it where it is defined.
- Enforced by RuboCop: `Style/Documentation` for classes and modules,
  `Style/DocumentationMethod` (off by default) for methods. Both skip `test/`,
  matching RuboCop's own default, so test cases stay uncommented — their names
  state the expectation.
- Constants have no cop; keep them commented by hand.
- Keep these comments to a single line whenever possible. If one line cannot
  carry it, cut the aside rather than the rule — the detail belongs in the
  commit message. Multi-line is a last resort, not a default.

#### Never freeze strings

- Never write `# frozen_string_literal: true`. No file gets a magic comment.
- Never call `.freeze` on a string, constant or not. Array and hash constants
  are still worth freezing by hand.
- Where a constant only names something, prefer a symbol over a string — it is
  immutable already, so the question does not arise.
- Enforced by RuboCop: `Style/FrozenStringLiteralComment` is `never`, and
  `Style/MutableConstant` is disabled because it demands `.freeze` on string
  constants and cannot be told to skip them.

#### Single quotes by default

- Always use single-quoted strings.
- Double quotes only when the string genuinely needs them: interpolation
  (`"#{name}"`) or escape sequences (`"\n"`, `"\x0"`).
- Enforced by RuboCop: `Style/StringLiterals` and
  `Style/StringLiteralsInInterpolation` are both set to `single_quotes`.
- This covers views too, `.html` and `.html.erb` included, and applies to HTML
  attributes and CSS values as much as to Ruby: `<th scope='col'>`, not
  `<th scope="col">`. RuboCop does not lint views, so this half is on us.
- A Ruby string containing single quotes then *needs* double quotes, which is
  why assertions on this markup read `"<table class='table table-hover'>"`.

### INTERNATIONALIZATION

#### Eastern time

- `config.time_zone = 'Eastern Time (US & Canada)'`. That is what `Time.zone`
  means, and what a form reads and a timestamp renders as for anyone whose browser
  has not said otherwise.
- Since 2026-08-25 it is the *fallback* rather than the answer. On the gem's own
  screens the reader's browser reports its zone into a `recourse-zone` cookie and
  `Recourse::Zoning` wraps the action in `Time.use_zone` of it, so a page, the
  table on it and the field that edits a value are all drawn against the reader's
  clock. A browser that has not said, or has named a zone
  `ActiveSupport::TimeZone[]` does not know, gets the line above.
- That is still not the gem setting a host's time zone, and the rule below stands.
  `Time.use_zone` takes a block and puts the old zone back in an `ensure`, and
  `Time.zone` is per-thread state rather than config — `config.time_zone` is never
  written, and a host's own screens are drawn against it as before.
- Move the zone, never the text. Rewriting a rendered `<time>` in the browser
  localizes what a page *reads* and leaves what it *writes* behind, so a reader
  would find one time on a record's page and another in the box that edits it. The
  server knowing the zone is what keeps the two agreeing — and is why a `date`
  never shifts, having no hour for a zone to move it by.
- Storage stays UTC. Never touch `config.active_record.default_timezone` — the
  database keeps UTC and Rails converts on the way in and out, which is the whole
  reason the zone can be a per-request decision at all.
- A rule for apps we write. The gem never sets a host's time zone.

#### Every user-facing string is in the locale file

- They live in `config/locales/recourse.en.yml` and nowhere else, read back with
  `t` in a view or a controller and `I18n.t` in a model. This replaces the earlier
  deferral, which was to run "until there are enough strings to be worth a locale
  file": twenty was enough.
- Keys are alphabetical, the model's name arrives as `%{model}` or `%{models}`,
  and a group only earns nesting when its lines are one message — the delete
  warning's four are `deletion.*`, everything else is flat.
- The point is not translation, which is still nobody's plan. It is that a host
  can reword `Add contact` by writing one key, rather than reopening a helper.

#### The State model

- A `State` model always represents the United States, and always has exactly
  these three attributes, each non-null and unique: `code` (two capital
  letters, `'CA'`), `fips` (two digits, `'06'`), `name` (`'California'`).
- It always ships with a migration that creates the table *and* backfills it
  from the official list, so an app never starts with an empty states table.
  Source of truth: https://www2.census.gov/geo/docs/reference/state.txt
- 51 rows: the 50 states plus the District of Columbia. Territories are not
  states, so `PR`, `GU`, `VI`, `AS`, `MP` and `UM` are left out.
- `fips` is a string, never an integer — `'06'` must keep its leading zero.
- Enforce all of it in the database too: unique indexes, `null: false`,
  `limit: 2`, and check constraints for the two-letter and two-digit shapes.

#### The County model

- A `County` has a unique non-null 5-digit `fips` string, a non-null `name`, and
  belongs to a `state`. `name` is deliberately *not* unique — more than twenty
  states have a Washington County.
- Creating a counties table always comes with a migration that backfills all
  3,143 counties of the 50 states plus DC, each joined to the right `states` row.
  Source: https://www2.census.gov/geo/docs/reference/codes2020/national_county2020.txt
- The first two digits of a county's `fips` are its state's `fips`. Check that
  after backfilling, not just the row count — by hand, since a migration does
  not get a test.
- Territories are left out, matching the states table.
- The 3,143 rows live in `db/counties.txt`, not inside the migration. Migrations
  are exempt from the file-length rule, so this is a decision rather than a
  workaround: leave the data in the file and do not inline it.
- The database enforces it too: unique index on `fips`, `null: false`, a
  five-digit check constraint, and a real foreign key to `states`.

#### The ZIP model

- A `ZIP` has a unique non-null 5-digit `code`, a non-null `city`, a non-null
  `time_zone`, belongs to a `county`, and optionally belongs to a `market`.
- The class is `ZIP`, not `Zip`, because the acronym is registered. The plural is
  not registered, so everything Rails names from the `zips` path keeps Rails'
  spelling: `ZipsController`, and `create_zips.rb` defining `CreateZips`. A
  migration whose class does not match only breaks on a migrate from zero, which
  is why a reset is the real test.
- Creating a zips table always comes with a migration that backfills it: every
  ZIP, matched to the county it mostly belongs to and the main city in it.
- `time_zone` holds a Rails zone name, never an IANA identifier. The source mixes
  both, so the backfill normalizes on the way in, matching each identifier by its
  offset and DST rules: Detroit and the Kentucky zones to Eastern, Indiana's
  Eastern zones to `Indiana (East)`, Knox and Tell_City to Central, Boise to
  Mountain, Anchorage and Nome to Alaska, Honolulu to Hawaii. Nothing should
  survive that `ActiveSupport::TimeZone::MAPPING` does not name — worth checking
  by hand after a backfill, since a migration does not get a test.
