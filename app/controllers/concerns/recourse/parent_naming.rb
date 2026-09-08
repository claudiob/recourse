module Recourse
  # Names the record a nested route sits under, so a host's own view can read it.
  module ParentNaming
  private

    # `/providers/5/openings` sets `@provider`, the way a hand-written controller would
    # -- the contract `ResourceResolution` already keeps for the record a page is about,
    # kept here for the one above it, and the reason a host needs no scoping concern of
    # its own to write a form or a row that names the parent.
    #
    # Named from the route rather than from the association, because the two need not
    # meet through a key: a page listing every vertical under a provider is nested by
    # the path alone, and no `belongs_to` joins the two. Asked the way
    # `attachment_parent_from` asks it, which is the same question about the same path.
    def name_parent
      model = parent_named_model
      return unless model

      record = named_parent_record model
      instance_variable_set "@#{model.model_name.singular}", record if record
    end

    # The model the path above this one is named after, where there is one to name. A
    # bare action has no model, and a path may name a class that answers no queries.
    def parent_named_model
      path = Recourse.parent_of controller_path
      model = path && Recourse.model?(path)

      model if model.respond_to? :find
    end

    # What `find_parent` already resolved, where that is the record the path names, so
    # the ordinary case costs no second query -- and a lookup of its own where it is
    # not, which is every nesting the models are not joined by a key.
    def named_parent_record(model)
      return @recourse_parent if @recourse_parent.is_a? model

      id = request.path_parameters[:"#{model.model_name.singular}_id"]

      model.find id if id
    end
  end
end
