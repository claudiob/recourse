# Types this app has and Active Record does not: money, a share of it, two numbers
# that count nothing, and the zone a place keeps its hours in. A
# `decimal` column says how many digits it keeps and nothing about what they mean, so
# a page cannot tell `hourly_rate` from `commission_rate` — and it is the app, not the
# gem, that knows which is which.
#
# Registered with a block, so `Monetary` is autoloaded when a model first asks for the
# type rather than during boot.
ActiveSupport.on_load :active_record do
  ActiveRecord::Type.register(:monetary) { |_name, **options| Monetary.new(**options) }
  ActiveRecord::Type.register(:percentage) { |_name, **options| Percentage.new(**options) }
  ActiveRecord::Type.register(:month) { Month.new }
  ActiveRecord::Type.register(:year) { Year.new }
  ActiveRecord::Type.register(:time_zone) { Zone.new }
end

# The migration side of the same two words: `t.monetary :hourly_rate` writes the
# decimal `Monetary` reads back. Rails keeps `define_column_methods` private, so a column method
# is written out and delegates to the one it is a kind of.
module MonetaryColumns
  # A column holding money, in the one shape this app keeps it in.
  def monetary(*names, **options)
    names.each { |name| decimal name, precision: Monetary::PRECISION, scale: Monetary::SCALE, **options }
  end

  # A column holding a share of something, in the one shape this app keeps those in.
  def percentage(*names, **options)
    names.each do |name|
      decimal name, precision: Percentage::PRECISION, scale: Percentage::SCALE, **options
    end
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include MonetaryColumns
