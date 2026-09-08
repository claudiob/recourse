# A share of something rather than an amount of it: `15.5` means 15.5%, so two decimal
# places and two digits before them — the shape `providers.commission_rate` already
# has, since a type that disagreed with its column would promise what the database
# would then refuse.
class Percentage < ActiveRecord::Type::Decimal
  PRECISION = 4
  SCALE = 2

  def initialize(precision: PRECISION, scale: SCALE, **)
    super
  end

  # What `type_for_attribute` answers, which is what a page formats by.
  def type = :percentage
end
