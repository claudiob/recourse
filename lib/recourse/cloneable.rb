require 'active_support'

module Recourse
  # An unsaved copy of a record: its own values, less the ones no second row may hold,
  # and whatever its model says a copy carries with it. Every model carries this and
  # acts on the ones that asked, `recourse_cloned` naming nothing by default -- so a
  # model that says nothing is copied on its own, which is what a clone was before.
  module Cloneable
    extend ActiveSupport::Concern

    # The copy, still unsaved and still unvalidated, so a caller may set what a reader
    # typed over it before any of it is written. Recursive by construction: a child is
    # copied by asking it for its own, which is where a host's override of this reaches
    # each level -- `super.tap { |copy| copy.promoted_plan_id = nil }` for a key that
    # would otherwise point back at the record this one was copied from.
    def recourse_deep_clone
      dup.tap do |copy|
        Recourse.reset_clone copy
        copy.assign_attributes recourse_cloned_associations
      end
    end

  private

    # Compacted, so a name whose record is not there -- an unattached file, a `has_one`
    # nobody has written -- is left out rather than assigned as nothing, which for an
    # attachment would read as an instruction to detach.
    def recourse_cloned_associations
      self.class.recourse_cloned.index_with { |name| recourse_cloned_target name }.compact
    end

    # What one name comes to, by what kind of association it is. A reflection the model
    # has no `reflect_on_association` for is one Active Storage declared, which keeps its
    # own register.
    def recourse_cloned_target(name)
      reflection = self.class.reflect_on_association name
      return recourse_cloned_files name unless reflection
      # The same rows rather than copies of them: a record joined to a city is joined to
      # that city, and a second city with the same name would be a different place.
      return association(name).reader.to_a if reflection.macro == :has_and_belongs_to_many

      recourse_cloned_records association(name).reader
    end

    # `has_one` answers with one record or none, `has_many` with a collection.
    def recourse_cloned_records(target)
      return target&.recourse_deep_clone unless target.respond_to? :map

      target.map(&:recourse_deep_clone)
    end

    # The blobs rather than the attachments: the copy writes attachment rows of its own
    # pointing at the files the record already has, so nothing is uploaded twice. Read
    # the way `Helpers::Blobs` reads them, through whichever of the two associations
    # Active Storage named -- a shelf of files answers to one and a single file to the
    # other, and only the reflection says which.
    def recourse_cloned_files(name)
      many = Recourse.attachment_many? self.class, name.to_s
      blobs = association(many ? :"#{name}_blobs" : :"#{name}_blob").reader

      many ? blobs.to_a : blobs
    end
  end
end

# Beside `Arranged`'s own: what a copy carries is the model's word, and a model that
# never says it is copied on its own.
ActiveSupport.on_load :active_record do
  include Recourse::Cloneable
end
