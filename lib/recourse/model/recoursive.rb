# A module to manage administered resources.
module Recourse
  # Ensures every Active Record object is compatible with recourse.
  module Recoursive
    # Return the associations to .include when loading all the resources.
    def recourse_includes
      %i[]
    end

    # Return the actions available for the model (among :new, :edit, :destroy)
    def recourse_actions
      default = %i[new edit destroy]
      options = Recourse.resources[name.underscore.pluralize.to_sym]
      (Array(options.fetch :only, default) & default) - Array(options.fetch :except, [])
    end

    # Return the fields to .order when loading all the models.
    def recourse_order
    end

    # Return whether the content to display all the models can be cached.
    def recourse_cachable?
      true
    end

    # Return whether the model has a position field to use for drag'n'drop sorting.
    def recourse_positionable?
      false
    end

    # @return [Boolean] whether Ransack attributes are defined on the resource.
    def recourse_searchable?
      ransackable_attributes.any? || ransortable_attributes.any?
    end
  end
end
