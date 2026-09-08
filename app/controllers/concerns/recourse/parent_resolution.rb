module Recourse
  # Finds the record a nested route names, so `/counties/5/zips` lists county 5's
  # ZIPs, builds ZIPs inside it, and answers 404 when no county 5 exists.
  module ParentResolution
    extend ActiveSupport::Concern

    included do
      before_action :find_parent
    end

  private

    # An attachment's parent is the other one the routes can name and no key points
    # at: a blob holds nothing pointing back, the way the far side of a join does not.
    def find_parent
      @recourse_parent_association = parent_association
      @recourse_parent = if @recourse_parent_association
                           parent_model.find parent_id
                         else
                           attachment_parent
                         end

      name_parent
    end

    # What the route settled and every action honours: the index lists rows carrying
    # these columns, and `new` and `create` build records that do. A listing that
    # edits a join is the exception, and lists every row of the far side: the parent
    # is what the buttons write, not what the rows have in common. A polymorphic key
    # is written as the association rather than as the column, so the class name lands
    # beside the id — a key without its type points into every table at once.
    def parent_columns
      return {} if resource_join || attachment_reflection || @recourse_parent_association.nil?
      return { @recourse_parent_association.name => @recourse_parent } if polymorphic_parent?

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing. A
    # join's own keys count too: the far side of a many-to-many holds none pointing
    # at the parent, which is what the join row is for. A key naming no one table is
    # asked last, and asked the other way round.
    def parent_association
      associations = own_references + join_references

      associations.find { |one| path_names? one.name } || polymorphic_parent
    end

    # A host may serve a page over something that is no Active Record model at all --
    # an aggregate it assembles itself, or a verb with no class behind it whose action
    # the host answers itself -- and neither answers a question about keys. The routes
    # still named a parent, and the host still finds it.
    def own_references
      return [] unless resource_model? && resource_class.respond_to?(:recourse_references)

      resource_class.recourse_references
    end

    def join_references
      resource_join ? resource_join.recourse_references : []
    end

    def resource_join
      Recourse.join_of controller_path
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
