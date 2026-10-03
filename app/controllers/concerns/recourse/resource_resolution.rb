module Recourse
  # Resolves what a route names: the model behind it, the record an id points at,
  # and the attributes a form may submit for one.
  module ResourceResolution
  private

    # A singular resource is reached with no id — `/places/5/memo` names the record by
    # the path it hangs off rather than by a key of its own — so it is read off the
    # parent instead, under the name the route already gives it. Where the parent has
    # no association of that name the record is still the host's to find, in a
    # controller of its own.
    def find_resource
      return assign resource_class.find(params.expect(:id)) if params.key? :id
      return unless singular_reflection

      record = @recourse_parent.association(singular_reflection.name).reader

      record ? assign(record) : missing_record
    end

    # The parent's association of this resource's own name, whichever kind it is: a
    # `has_one` where the parent keeps the record, a `belongs_to` where it points at
    # one. `reflect_on_association` rather than a rescue, so a name the parent has
    # never heard of reads as nothing to resolve rather than as an error.
    def singular_reflection
      @recourse_parent&.class&.reflect_on_association controller_name.singularize
    end

    # Nothing found, which for a resource routed `new` means the page that makes one:
    # a `has_one` nobody has written yet is a form to fill in, not an absence to read.
    # Where no `new` is drawn, nothing is assigned and the page says so instead.
    def missing_record
      redirect_to url_for(action: :new) if Recourse.routed? controller_path, 'new'
    end

    # And the other way, before a form is drawn: a singular resource holds at most one,
    # so where the parent already keeps it there is nothing for `new` to make and the
    # page that reads it answers instead. The mirror of `missing_record`, which sends a
    # reader here when there is none yet. Where no `show` is drawn the form stands, that
    # being the only page the routes gave this record.
    def redirect_to_existing_record
      return unless singular_reflection && Recourse.routed?(controller_path, 'show')
      return unless @recourse_parent.association(singular_reflection.name).reader

      redirect_to url_for(action: :show)
    end

    def assign(record)
      @recourse = record
      instance_variable_set "@#{controller_name.singularize}", record
    end

    # Whether there is a model behind this page at all. A bare action has none: it is a
    # verb the host answers itself — `recourse :sweep, only: :create` — labelled from the
    # path alone, and still a `RecoursesController`, that being where a host keeps the
    # filters guarding its admin. So what runs on every request asks this first, and the
    # actions the gem serves reach for the model again and raise where it is missing.
    # Asked of `resource_class`, which a bookmark answers from the listing.
    def resource_model?
      resource_class.present?
    rescue Error
      false
    end

    # The model the route is named after — or Active Storage's, where the name is
    # something the parent has attached rather than a model of this app's own.
    def resource_class
      return ActiveStorage::Blob if attachment_reflection

      recourse_model
    end

    # The model this screen is about, and the second thing a host overrides to put a
    # page of its own behind a screen the gem otherwise draws whole:
    # `def recourse_model = Location`. The route's own name answers by default, which
    # asks the app for a class of that name — so a page listing what a measurement
    # answers rather than what a table holds is named for the answer and has no class
    # to match it. Private, the way `recourse_relation` beside it is: naming a model
    # adds no action.
    def recourse_model
      Recourse.model controller_name
    end

    # What the page calls one of its rows: the model's own word, or the route's for a
    # page of files — `Photo was deleted.`, never `Blob`.
    def human_name
      return controller_name.singularize.humanize if attachment_reflection

      resource_class.model_name.human
    end
  end
end
