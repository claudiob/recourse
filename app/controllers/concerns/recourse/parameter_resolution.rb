module Recourse
  # Resolves what a form sent: the attributes a record may be written with, read back
  # from what the route names and what the model lets a screen set.
  module ParameterResolution
  private

    # What a form may submit: every column a user may set, less the ones the model
    # keeps off its screens. The other thing a host overrides, and for the same
    # reason as `recourse_relation` — a form of its own asks for what it asks for,
    # which may be a hidden column or an attribute that is no column at all:
    # `def resource_params = params.expect(provider: %i[name cid])`.
    def resource_params
      # The parent is merged after resolving, so the one the route names is never
      # mistaken for a label; the files go no further than the permit that let them
      # through, being attached rather than assigned.
      submitted_attributes.except(*Recourse.attachment_names(resource_class))
                          .merge parent_columns
    end

    # What the form sent, with a typed reference read back as the id it names. A bare
    # `Create` submits no attributes at all, so the key may be absent: the parent a
    # nested route names is everything such a record starts from.
    def submitted_attributes
      permitted = Recourse.editable_columns(resource_class) + attachment_filters
      key = controller_name.singularize.to_sym
      return {} unless params.key? key

      resolve_lists resolve_references(params.expect(key => permitted))
    end
  end
end
