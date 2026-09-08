# A year, which is a number that counts nothing — so it is not delimited at a thousand
# the way a quantity is: 2025 rather than 2,025.
class Year < ActiveRecord::Type::Integer
  def type = :year
end
