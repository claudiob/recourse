# A module to manage administered resources.
module Recourse
  # Ensures every Active Record object is compatible with recourse.
  module Ransack

    # Returns the associations that can be searched (by default: none).
    def ransackable_associations(auth_object = nil)
      %w[ ]
    end

    # Returns the associations that can be sorted by (by default: none).
    def ransortable_attributes(auth_object = nil)
      %w[ ]
    end
  end
end

ActiveRecord::Base.include Recourse::Ransack
