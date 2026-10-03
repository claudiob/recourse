module Admin
  # What a person wears, kept in the Admin module rather than at the top level: the
  # model a route in that module finds before any class of the same name outside it.
  class Badge < ApplicationRecord
    belongs_to :person
    # Kept like a place is, at a path named after the route rather than the module.
    has_many :bookmarks, as: :topic, dependent: :destroy

    validates :name, presence: true

    def to_s = name
  end
end
