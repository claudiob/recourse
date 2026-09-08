# Money, which is a decimal that means something: this app keeps eight figures of it
# and two decimal places, and says so once here rather than at every column.
class Monetary < ActiveRecord::Type::Decimal
  PRECISION = 10
  SCALE = 2

  def initialize(precision: PRECISION, scale: SCALE, **)
    super
  end

  # What `type_for_attribute` answers, which is what a page formats by. `:monetary`
  # rather than `:money`, which PostgreSQL has a native type of its own by that name —
  # a host on it would have to be told to shadow one, and there is nothing to gain by
  # taking the word.
  def type = :monetary
end
