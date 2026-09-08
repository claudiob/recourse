module Recourse
  # Resolves the record a `?cloned_id=` names, and the values a form opens on because of
  # it. Named beside the other resolutions rather than after `Recourse::Cloning`, which
  # is what a copy is actually made by.
  module CloneResolution
  private

    # The record being copied, or nothing where the query names none -- which is every
    # ordinary `new` and `create`. `find`, so an id naming nothing answers 404 here as it
    # does on every other page an id reaches, and through `resource_class` rather than
    # `recourse_relation`, so a copy is scoped the way `show` and `edit` already are.
    #
    # Kept under a name the form can read back: the page says what a copy carries, and
    # what it carries is the source's, not the blank record the fields are drawn from.
    def cloned_source
      return @recourse_clone_source if defined? @recourse_clone_source

      id = params[:cloned_id]
      @recourse_clone_source = (resource_class.find id if id.present?)
    end

    # The copy itself, placed where a new row goes: the source's own doing, level by
    # level, and then the one reset that is the writing's rather than the copying's.
    # Nothing where the query names no record, which is every ordinary `create`.
    def cloned_record
      source = cloned_source
      return unless source

      source.recourse_deep_clone.tap { |copy| Recourse.reset_position copy }
    end

    # What the form opens on: the source's own columns and no more. The tree it carries
    # is not walked to draw a page -- only `create` builds one, where it can be saved.
    def cloned_attributes
      source = cloned_source
      return {} unless source

      Recourse.clonable_attributes source
    end
  end
end
