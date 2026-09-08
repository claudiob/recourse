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
    # these columns, and `new` and `create` build records that do. A polymorphic key
    # is written as the association rather than as the column, so the class name lands
    # beside the id — a key without its type points into every table at once.
    def parent_columns
      return {} if @recourse_parent_association.nil?
      return { @recourse_parent_association.name => @recourse_parent } if polymorphic_parent?

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing. A key
    # naming no one table is asked last, and asked the other way round.
    def parent_association
      own_references.find { |one| path_names? one.name } || polymorphic_parent
    end

    # A host may serve a page over a verb with no class behind it, whose action the
    # host answers itself, and a verb answers no question about keys. The routes still
    # named a parent, and the host still finds it.
    def own_references
      resource_model? ? resource_class.recourse_references : []
    end

    def parent_id
      request.path_parameters[:"#{parent_key}_id"]
    end

    # The name the parent arrives under: the association's own, or — where the key
    # names no one table — the parent model's, since that is the word the route uses.
    def parent_key
      return @recourse_parent_association.name unless polymorphic_parent?

      parent_model.model_name.singular
    end

    # The class the id points at. `klass` raises on a polymorphic reflection, which
    # is the whole reason the routes are asked for that one instead.
    def parent_model
      return @recourse_parent_association.klass unless polymorphic_parent?

      Recourse.model Recourse.parent_of(listing_path)
    end

    def polymorphic_parent? = @recourse_parent_association&.polymorphic?

    def path_names?(name) = request.path_parameters.key?(:"#{name}_id")
  end
end
