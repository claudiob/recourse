module Recourse
  module Helpers
    # The buttons a record's pages carry: an action the routes drew under it that has
    # no page of its own for a link to sit on.
    module Buttons
    private

      # A nested resource routed `create` without an `index` is reached from nowhere, so
      # its button lives on the record it hangs off — beside the breadcrumbs. Which of
      # that record's pages is the host's business as much as the button is: the
      # routes say where it goes as well as whether it exists.
      def bare_action_buttons(record)
        Recourse.nested_under(card_path).filter_map do |nested|
          next unless bare_action_page? nested

          bare_action_button record, nested
        end
      end

      # Whether this is that page. An index is a page to reach the action from and a
      # `new` is a form to fill in on the way: either one means there is more to this
      # than a button. A nesting with no page anywhere stands on the record's own page,
      # since every other page of the record is about something else — a place's memos
      # are not where a sweep of the place is offered.
      def bare_action_page?(nested)
        return false if routed?(nested, 'index') || routed?(nested, 'new')

        record_page?
      end

      # The one page every record has, which is where a pageless action's button goes.
      def record_page?
        !resource_parent && controller.action_name == 'show'
      end

      # The `create` the routes drew on the collection, which needs no id: a member
      # action wants the row it acts on, and a row is what a table is for.
      def bare_action_button(record, nested)
        return unless routed? nested, 'create'

        [bare_action_label(nested), bare_action_url(record, nested), :post]
      end

      # The resource's own word, which a host renames in a locale like any other
      # model: `Add Jobber retrieval` rather than `Add booking exchange`. Led by
      # whatever namespace the routes put between the record and the action, because
      # that is the only thing telling two routes to the same model apart — without it
      # a `quick/memos` action and the `memos` beside it both read `Add memo`. The tab
      # for a nested index is named from the same split, so the two agree.
      def bare_action_label(nested)
        name, namespace = nested_segments nested, card_path
        model = Recourse.downcase Recourse.known_singular(name)
        lead = namespace_words namespace

        t 'recourse.add', model: [lead.presence, model].compact.join(' ')
      end

      def bare_action_url(record, nested)
        parent = card_path.split('/').last.singularize

        url_for controller: "/#{nested}", action: :create, "#{parent}_id": record.id
      end
    end
  end
end
