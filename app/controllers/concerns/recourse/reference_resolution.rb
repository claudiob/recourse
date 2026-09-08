module Recourse
  # Resolves a submitted foreign key back to an id, for a belongs_to whose label
  # is typed rather than picked from a menu.
  module ReferenceResolution
  private

    # A foreign key whose label is typed arrives as that label, so it is looked up
    # here. Nothing found leaves the key nil, and `belongs_to` reports it missing.
    def resolve_references(attributes)
      resource_class.recourse_references.each do |association|
        key = association.foreign_key.to_s
        next unless attributes.key?(key) && association.klass.recourse_typed_reference?

        attributes[key] = reference_id association, attributes[key]
      end

      attributes
    end

    # The row a label names, where it names one. Two rows are not an answer: a label is
    # offered to be typed because it is short enough to say, not because it identifies
    # anything, and a table whose label is not unique has rows that answer to the same
    # words. Picking the first of them would point the key somewhere nobody asked for
    # and report that it worked, so the write is refused instead and the field says why.
    def reference_id(association, label)
      found = association.klass.where(association.klass.recourse_label => label).limit 2
      return found.first&.id unless found.length > 1

      ambiguous_references[association.name] = label
      nil
    end

    # What a label matched more than one of, kept until the record is built: the error
    # belongs on the record, and there is none yet when the parameters are read.
    def ambiguous_references
      @ambiguous_references ||= {}
    end

    # Whether any label named more than one row — and, where one did, says so on the
    # field that asked. Added after validating rather than before, since validating
    # clears what was there, so such a record is never saved at all.
    def ambiguous_references?(record)
      return false if ambiguous_references.empty?

      ambiguous_references.each do |name, label|
        record.errors.add name, :ambiguous, message: t('recourse.ambiguous', label: label)
      end

      true
    end
  end
end
