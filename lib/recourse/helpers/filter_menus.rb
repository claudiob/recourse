module Recourse
  module Helpers
    # The markup a filter menu is: the records it lists, the order they read in, and
    # the count beside each where the model keeps one.
    module FilterMenus
    private

      def filter_combobox(predicate, title, recourses)
        label = recourses.klass.recourse_label
        counter = filter_counter recourses.klass
        # What it reads as when nothing is ticked, so the way back is a line in the menu.
        models = Recourse.model_title recourses.klass, lower: true

        filter_menu predicate, title, nil, t('recourse.all', models: models),
                    label: label.to_s, counter: counter,
                    recourses: filter_options(recourses, label, counter)
      end

      # The commonest choice first where the model keeps a count, since a menu is read
      # from the top and most requests want the option most rows are behind — and by
      # name where it keeps none. The name breaks ties, or two markets on the same
      # number would swap places between one request and the next.
      def filter_options(recourses, label, counter)
        return recourses.select(:id, label).order label unless counter

        recourses.select(:id, label, counter).order counter => :desc, label => :asc
      end

      # The column on the model a filter lists that counts the rows being filtered —
      # `markets.zips_count` on `/zips`. Read from the counter caches that model keeps
      # rather than from a column named after this one, so a `zips_count` nobody
      # maintains is not a count. None on a nested page: the count is of every row in
      # the table, and the page shows the parent's share of them, which nothing counted.
      def filter_counter(klass)
        return if resource_parent

        Recourse.counters(klass).find { |_, one| one.klass == resource_model }&.first
      end

      # Never invalid and never required: a filter narrows rather than sets.
      def filter_menu(predicate, title, values, all, **)
        render('recourses/combobox', name: "q[#{predicate}]", id: "q_#{predicate}",
                                     placeholder: title, multiple: true, aria_label: title,
                                     selected: filter_values(predicate), small: true,
                                     all: all, values: Array(values), **)
      end

      # A multiple select submits one value per pick, and a link carries them the same way.
      def filter_values(predicate)
        Array(query_params[predicate]).map(&:to_s).compact_blank
      end
    end
  end
end
