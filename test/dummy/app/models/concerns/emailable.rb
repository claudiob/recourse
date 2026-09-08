# Encrypts a model's email so it stays unique, queryable and case-insensitive.
module Emailable
  extend ActiveSupport::Concern

  included do
    encrypts :email, deterministic: true, downcase: true
  end
end
