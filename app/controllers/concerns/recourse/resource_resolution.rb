module Recourse
  # Resolves what a route names: the model behind it, the record an id points at,
  # and the attributes a form may submit for one.
  module ResourceResolution
  private

    # The record the id names, under the name Rails would use. `find`, so an id naming
    # nothing answers 404.
    def find_resource = assign resource_class.find(params.expect(:id))

    def assign(record)
      @recourse = record
      instance_variable_set "@#{controller_name.singularize}", record
    end

    # Whether there is a model behind this page at all. A bare action has none: it is a
    # verb the host answers itself — `recourses :sweeps, only: :create` — labelled from the
    # path alone, and still a `RecoursesController`, that being where a host keeps the
    # filters guarding its admin. So what runs on every request asks this first, and the
    # actions the gem serves reach for the model again and raise where it is missing.
    # Asked of `resource_class`, which a bookmark answers from the listing.
    def resource_model?
      resource_class.present?
    rescue Error
      false
    end

    # The model the route is named after.
    def resource_class = recourse_model

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

    def human_name
      resource_class.model_name.human
    end

    # What a form may submit: every column a user may set, less the ones the model
    # keeps off its screens. The other thing a host overrides, and for the same
    # reason as `recourse_relation` — a form of its own asks for what it asks for,
    # which may be a hidden column or an attribute that is no column at all:
    # `def resource_params = params.expect(provider: %i[name cid])`.
    def resource_params
      # The parent is merged after resolving, so the one the route names is never
      # mistaken for a label.
      submitted_attributes.merge parent_columns
    end

    # What the form sent, with a typed reference read back as the id it names. A bare
    # `Create` submits no attributes at all, so the key may be absent: the parent a
    # nested route names is everything such a record starts from.
    def submitted_attributes
      permitted = Recourse.editable_columns resource_class
      key = controller_name.singularize.to_sym
      return {} unless params.key? key

      resolve_lists resolve_references(params.expect(key => permitted))
    end
  end
end
