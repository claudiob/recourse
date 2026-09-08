module Recourse
  # An index over what a record has attached rather than over a model of its own.
  # `has_many_attached :photos` and `recourses :photos, only: :index` under the same
  # record is the whole declaration: Rails already generates the association this
  # reads, and Active Storage already has the model it lists.
  module AttachmentResolution
    extend ActiveSupport::Concern

  private

    # The attachment this page lists, or nil where the name is a model like any
    # other. `has_one_attached` is not one: a single file is a value on the record's
    # own page, and a table of one row says less than the field it replaced.
    def attachment_reflection
      return unless defined?(ActiveStorage::Reflection) && attachment_parent

      reflection = attachment_parent.class.attachment_reflections[controller_name]

      reflection if reflection.is_a? ActiveStorage::Reflection::HasManyAttachedReflection
    end

    # The record the path names, read off the routes rather than off a key: a blob
    # holds none pointing back, which is what the attachment row between them is for.
    def attachment_parent
      return @attachment_parent if defined? @attachment_parent

      parent = Recourse.parent_of controller_path
      @attachment_parent = parent && attachment_parent_from(parent)
    end

    def attachment_parent_from(parent)
      model = Recourse.model parent
      id = request.path_parameters[:"#{model.model_name.singular}_id"]

      model.find_by id: id if id
    end

    # The blobs themselves, through the association `has_many_attached` generated —
    # a real relation, so the search, the sort and the page all still apply.
    def attachment_relation
      attachment_parent.association(:"#{controller_name}_blobs").reader
    end
  end
end
