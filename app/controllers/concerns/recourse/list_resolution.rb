module Recourse
  # Resolves a submitted list back to the values it holds, for a column that keeps
  # several of them where a form can only send one string.
  module ListResolution
  private

    # A list is typed one value to a line and arrives as those lines, so it is split
    # back here — the same place a typed reference is looked up, and for the same
    # reason: no host model needs a virtual attribute and no host needs a strong
    # parameter of its own. A line that is only spaces is not a value, and neither is
    # an empty box: both leave the list empty rather than holding one blank string.
    def resolve_lists(attributes)
      list_columns.each do |column|
        next unless attributes.key? column

        attributes[column] = attributes[column].to_s.lines.filter_map do |line|
          line.strip.presence
        end
      end

      attributes
    end

    def list_columns
      resource_class.column_names.select { |column| Recourse.list_column? resource_class, column }
    end
  end
end
