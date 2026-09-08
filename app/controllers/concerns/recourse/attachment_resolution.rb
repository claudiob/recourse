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
      return unless defined?(ActiveStorage::Reflection) && @recourse_parent

      reflection = @recourse_parent.class.attachment_reflections[controller_name]

      reflection if reflection.is_a? ActiveStorage::Reflection::HasManyAttachedReflection
    end

    # The blobs themselves, through the association `has_many_attached` generated —
    # a real relation, so the search, the sort and the page all still apply.
    def attachment_relation
      @recourse_parent.association(:"#{controller_name}_blobs").reader
    end
  end
end
