# A month of the year as the number of one, which is how a machine keeps a month and
# not how anybody says it. The type is what tells a screen the difference: a month is a
# small integer, and so is a count of anything else.
class Month < ActiveRecord::Type::Integer
  def type = :month
end
