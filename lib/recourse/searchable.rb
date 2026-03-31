# A module to manage administered resources.
module Recourse
  # Extends any model to be searchable with Ransack.
  module Searchable
    # Returns the attributes that can be searched.
    def ransackable_attributes(auth_object = nil)
      %w[ ]
    end

    # Returns the associations that can be searched (by default: none).
    def ransackable_associations(auth_object = nil)
      %w[ ]
    end

    # Returns the associations that can be sorted by (by default: none).
    def ransortable_attributes(auth_object = nil)
      %w[ ]
    end

    # @note to be overriden by subclasses -- the name of the field to search with.
    def search_field
    end

    # @note to be overriden by subclasses -- the placeholder for the field to search with.
    def search_placeholder
    end

    # @note to be overriden by subclasses -- the name of the field to filter by.
    def filter_field
    end

    # @note to be overriden by subclasses -- the prompt for the field to filter by.
    def filter_prompt
    end

    # @note to be overriden by subclasses -- the values for the field to filter by.
    def filter_choices
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend Recourse::Searchable
end
