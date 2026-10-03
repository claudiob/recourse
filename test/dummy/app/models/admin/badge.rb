module Admin
  # What a person wears, kept in the Admin module rather than at the top level: the
  # model a route in that module finds before any class of the same name outside it.
  class Badge < ApplicationRecord
    belongs_to :person

    validates :name, presence: true

    def to_s = name
  end
end
