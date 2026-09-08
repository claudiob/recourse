module Recourse
  module Helpers
    # What a nested index's tab on the parent's card reads as.
    module Tabs
    private

      # What a nested resource's tab reads as. For an index, a `has_many` of that name
      # counts its rows and lends its icon; a route the parent has no association for
      # is named after the path instead — an aggregate the host assembles, an Active
      # Storage attachment, a full index reached under a record. There is no model to
      # ask then, so such a tab carries neither an icon nor a count. A singular
      # resource is one record and never a list, so no association is asked for it at
      # all: a `has_many` of that name would count rows this page is not.
      def nested_tab_label(record, name, namespace, action)
        association = nested_association record, name if action == :index
        return association_tab_label record, association, namespace if association

        routed_tab_name name, namespace, action
      end

      def nested_association(record, name)
        record.class.reflect_on_all_associations(:has_many).find { |one| one.name.to_s == name }
      end

      # `Messages`, and `Booked messages` where a namespace leads — the same shape
      # the counted tab keeps. Humanized off the path for an index, since nothing else
      # answers; the model's own singular for one record, since there is a model to ask
      # and only ever one row of it. That singular is the word the bare action's button
      # takes, from the same split, so a tab and a button under one record cannot come
      # to disagree about what the resource is called.
      def routed_tab_name(name, namespace, action)
        lead = namespace_words namespace
        title = action == :show ? Recourse.known_singular(name) : name.humanize
        title = Recourse.downcase title if lead.present?

        [lead.presence&.upcase_first, title].compact.join ' '
      end

      # The icon is the counted model's own, whatever leads the words beside it.
      def association_tab_label(record, association, namespace)
        icon = Recourse.known_model_icon association.klass

        words = [icon && tag.i(class: "bi bi-#{icon}"), tab_name(record, association, namespace)]

        safe_join words.compact, ' '
      end

      # `8 ZIPs` where the record keeps a count — read off the record itself, no
      # query, like the column — and the bare `ZIPs` where it keeps none. A namespace
      # the routes drew leads either of those, so two nestings of one model read
      # apart: `10 visited places` beside `4 booked places`, `Visited places` beside
      # `Booked places`. Whatever leads earns the downcase, and a title that leads
      # keeps its capital — which is what puts these beside Show and Edit.
      def tab_name(record, association, namespace)
        count = tab_count record, association
        lead = [count, namespace_words(namespace)].compact_blank.join ' '
        title = Recourse.model_title association.klass, count: count, lower: lead.present?

        [lead.presence&.upcase_first, title].compact.join ' '
      end

      def tab_count(record, association)
        column = counter_column_of record.class, association

        record.attributes[column] if column
      end

      # `on_hold` reads as `on hold`, and an acronym among them keeps its capitals.
      # A nested path split where the parent's ends: whatever the routes drew between
      # the two — a `namespace`, usually nothing — and then the resource's own name.
      # `admin/people/quick/memos` under `admin/people` is `memos`, led by `quick`.
      # Both the tab and the button that stand for that route read it from here, so
      # the two cannot disagree about which words belong to the namespace.
      def nested_segments(nested, path)
        namespace = nested.delete_prefix("#{path}/").split '/'

        [namespace.pop, namespace]
      end

      def namespace_words(namespace)
        namespace.map { |segment| Recourse.downcase segment.humanize }.join ' '
      end

      def counter_column_of(model, association)
        model.recourse_counters.find { |_, one| one == association }&.first
      end
    end
  end
end
