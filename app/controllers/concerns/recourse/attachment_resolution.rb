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

    # The record the path names, asked before the model is settled: a blob holds no key
    # pointing back at what it hangs off, and what this page is about turns on which
    # record that is. The same lookup `find_parent` falls back on, kept for the request.
    def attachment_parent
      return @attachment_parent if defined? @attachment_parent

      @attachment_parent = path_parent
    end

    # The blobs themselves, through the association `has_many_attached` generated —
    # a real relation, so the search, the sort and the page all still apply.
    def attachment_relation
      attachment_parent.association(:"#{controller_name}_blobs").reader
    end

    # The row joining the record to one of its files, which is what a delete on this
    # page removes: the file stays as long as anything else still points at it, and
    # Active Storage purges it once nothing does.
    def attachment_of(blob)
      attachment_parent.association(:"#{controller_name}_attachments").reader.find_by! blob: blob
    end
  end
end
