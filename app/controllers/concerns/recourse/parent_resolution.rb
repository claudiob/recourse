module Recourse
  # Finds the record a nested route names, so `/counties/5/zips` lists county 5's
  # ZIPs, builds ZIPs inside it, and answers 404 when no county 5 exists.
  module ParentResolution
    extend ActiveSupport::Concern

    included do
      before_action :find_parent
    end

  private

    # The record a key points at where the resource has one, and otherwise the record
    # the path names: a page nested by the path alone — the memos of a team no memo
    # belongs to — still sits under something.
    def find_parent
      @recourse_parent_association = parent_association
      @recourse_parent = @recourse_parent_association ? parent_model.find(parent_id) : path_parent

      name_parent
    end

    # The record the segment above this one names, read off the routes rather than off
    # a key, or nil where the path names nothing or the name is no model's.
    def path_parent
      parent = Recourse.parent_of controller_path
      model = parent && Recourse.model?(parent)
      return unless model

      id = request.path_parameters[:"#{model.model_name.singular}_id"]
      model.find_by id: id if id
    end

    # What the route settled and every action honours: the index lists rows carrying
    # these columns, and `new` and `create` build records that do.
    def parent_columns
      return {} if @recourse_parent_association.nil?

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing.
    def parent_association
      own_references.find { |one| path_names? one.name }
    end

    # A host may serve a page over a verb with no class behind it, whose action the
    # host answers itself, and a verb answers no question about keys. The routes still
    # named a parent, and the host still finds it.
    def own_references
      resource_model? ? resource_class.recourse_references : []
    end

    def parent_id
      request.path_parameters[:"#{@recourse_parent_association.name}_id"]
    end

    def parent_model = @recourse_parent_association.klass

    def path_names?(name) = request.path_parameters.key?(:"#{name}_id")
  end
end
