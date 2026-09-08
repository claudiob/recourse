module Recourse
  module Helpers
    # The menu a time zone is picked from, and the short list it opens on.
    module Zones
    private

      # Every zone Rails knows, or the narrower list a host's own type nominates: an app
      # serving one country has no use for the other hundred and twenty, and the type is
      # already what the gem asks whether a column holds a zone at all.
      #
      # It opens on the few that type calls common, and the rest arrive behind
      # `All time zones` the way a filter's unused options do: forty of them is a page to
      # read, and four answer for most records.
      def zone_combobox(form, column)
        type = resource_model.type_for_attribute column
        values = zone_names type, :values, ActiveSupport::TimeZone.all.map(&:name)
        shown = zone_names type, :common, values

        render 'recourses/combobox', **combobox_locals(form, column),
                                     values: values, shown: shown,
                                     all: zone_reveal(column, values, shown)
      end

      # What the type says, where it says anything: neither list is a question every type
      # has an answer to, and what Rails knows is the answer when one has none.
      def zone_names(type, name, fallback)
        type.respond_to?(name) ? Array(type.public_send(name)) : fallback
      end

      # The line that asks for the rest of them, and nothing where there is no rest.
      def zone_reveal(column, values, shown)
        return unless shown.size < values.size

        t 'recourse.all', models: Recourse.downcase(resource_column_title(column).pluralize)
      end
    end
  end
end
