# Everything a screen can be asked to draw, in one model: a column of every kind the
# gem formats, a foreign key that is typed beside one that is picked, an enum, two
# encrypted columns, and one the model keeps off every page.
class Place < ApplicationRecord
  include Phonable, Recoursive

  # What a place is at, one per line saying what that state means.
  STATUSES = [
    :draft, # written down and nothing more (default)
    :open, # taking bookings
    :closed, # taking none, and not coming back
  ].freeze

  # Lower case, digits and hyphens, starting and ending on a character: what a URL
  # can carry without escaping. A form reads this back as its `pattern`.
  SLUGS = /\A[a-z0-9]+(-[a-z0-9]+)*\z/

  enum :status, STATUSES.index_by(&:itself)

  # At most one, which is what a singular resource stands for.
  has_one :audit, dependent: :destroy

  # The same, and made by pressing a button rather than by filling in a form.
  has_one :seal, dependent: :destroy

  # And the one a place is written about, which points back polymorphically.
  has_one :memo, as: :about

  # 101 of them, so a form asks for a code; three teams, so a form lists them.
  belongs_to :zip, counter_cache: true
  belongs_to :team, counter_cache: true, touch: true
  # The parent a nested route answers, and optional, so a place can stand alone.
  # Counted, which is what earns the person's card a tab reading `3 places`.
  belongs_to :person, optional: true, counter_cache: true
  # Files rather than records: a page of them lists Active Storage's own blobs, and
  # the gem needs no model of this app's to draw one.
  has_many_attached :photos
  # And one file rather than a shelf of them, which is a value on the record's own
  # page and a field on its form rather than a table of a single row.
  has_one_attached :floor_plan

  # The other half of a bookmark, which is also what opts this table into the column:
  # a model that cannot hold one has not declared one. Teams declare none, so their
  # table opens at its first attribute.
  has_many :bookmarks, as: :topic, dependent: :destroy

  # Money and a share of it, told apart by their types and not by their names.
  attribute :hourly_rate, :monetary
  # Two numbers that count nothing, and are told apart from the counts above by their
  # types rather than by their names: one reads as a word, the other as its digits.
  attribute :busiest_month, :month
  attribute :founded_year, :year
  attribute :commission_rate, :percentage
  # And a string that is one of a fixed list Rails knows, which is what earns it a menu.
  attribute :time_zone, :time_zone

  # A list of values rather than one, which is what SQLite has no column type for: on
  # PostgreSQL this would be `t.text :tags, array: true`, and `serialize` is the same
  # thing said where that option raises. Both report a type wrapping a subtype, which
  # is the only question the gem asks about either.
  serialize :tags, type: Array, coder: JSON

  # Queried and unique, so its ciphertext has to be the same every write.
  encrypts :secret, deterministic: true
  # Neither, so it need not be.
  encrypts :notes

  validates :name, presence: true
  # The unique index says so too, and a constraint the model keeps quiet about is one no
  # screen can honour: a copy of a place would have carried this one straight into it.
  validates :webhook_url, uniqueness: true, allow_nil: true
  # The column is `null: false`, so the model says so too — a constraint the model
  # keeps quiet about is one the browser cannot show and one a form finds out about
  # from the database, as a 500 rather than as a message beside the field.
  validates :status, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # A non-null boolean is included in the two, never present: `presence` rejects
  # `false` along with nil.
  validates :active, inclusion: { in: [true, false] }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
                     allow_nil: true

  with_options format: { with: SLUGS, message: 'is lower case, digits and hyphens' } do
    validates :slug, presence: true, uniqueness: true, length: { maximum: 20 }
  end
end
