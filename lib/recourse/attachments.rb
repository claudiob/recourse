# Reopened for what a record keeps beside its columns, which a form, a show page and
# the params a write permits each have to ask a model about.
module Recourse
  # What Active Storage was told a model has attached. Extended onto `Recourse`, so
  # every one of these is `Recourse.something` wherever it is called from.
  module Attachments
    # The attachments a screen offers, in the order the model declared them, less
    # whatever it asked to keep off one: `recourse_hidden :photos` hides a file exactly
    # as it hides a column. Empty for a class Active Storage never reached — an
    # aggregate, or a host that installed none of it — which is the same guard
    # `AttachmentResolution` already carries as `defined?(ActiveStorage::Reflection)`.
    def attachment_names(model)
      return [] unless model.respond_to? :attachment_reflections

      model.attachment_reflections.keys - hidden_columns(model)
    end

    # Whether that name holds several files or one, which is the only thing a field and
    # a write each need to know about it: a field offers `multiple` for the one and not
    # the other, and a write appends to the one where it replaces the other. Read off
    # the reflection's own `macro`, so neither of Active Storage's classes is named.
    def attachment_many?(model, name)
      model.attachment_reflections[name]&.macro == :has_many_attached
    end
  end

  extend Attachments
end
