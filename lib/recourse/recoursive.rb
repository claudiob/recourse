# A module to manage administered resources.
module Recourse
  # Ensures every Active Record object is compatible with recourse.
  module Recoursive
    # Return the associations to .include when loading all the resources.
    def recourse_includes
      %i[]
    end

    # Return the fields to .order when loading all the models.
    def recourse_order
    end

    # Return whether the content to display all the models can be cached.
    def recourse_cachable?
      true
    end

    # @return [Boolean] whether Ransack search attributes are defined on the resource.
    def recourse_searchable?
      ransackable_attributes.any? || ransackable_associations.any?
    end

    # @return [Boolean] whether Ransack sort attributes are defined on the resource.
    def recourse_sortable?
      ransortable_attributes.any?
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend Recourse::Recoursive
end
