# Normalizes a model's phone to bare digits and accepts only valid 10-digit ones.
module Phonable
  extend ActiveSupport::Concern

  # Ten digits; area and exchange codes cannot start with 0 or 1 (so 555-1234 fails).
  NORTH_AMERICAN_PHONES = /\A[2-9]\d{2}[2-9]\d{6}\z/

  included do
    normalizes :phone, with: ->(phone) { phone.delete('^0-9').delete_prefix '1' }
    with_options format: { with: NORTH_AMERICAN_PHONES, message: 'is not a valid phone number' } do
      validates :phone, allow_nil: true
    end
  end
end
