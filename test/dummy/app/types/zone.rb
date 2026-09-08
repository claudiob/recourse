# The time zone a place keeps its hours in, which is a string like any other until an
# attribute says otherwise: `Eastern Time (US & Canada)` is spelled exactly or not at
# all, and what tells a screen so is the type, never the name of the column.
#
# The type is also where the menu's two lists live, since both are this app's word
# rather than the gem's: which zones a place may be in, and which few of them a reader
# is offered before asking for the rest.
class Zone < ActiveRecord::Type::String
  # Every place here is in the United States, which is a fortieth of what Rails knows.
  ZONES = ActiveSupport::TimeZone.us_zones.map(&:name).freeze

  # And four of those answer for almost every one of them.
  COMMON = ['Eastern Time (US & Canada)', 'Central Time (US & Canada)',
            'Mountain Time (US & Canada)', 'Pacific Time (US & Canada)',].freeze

  def type = :time_zone

  def values = ZONES

  def common = COMMON
end
