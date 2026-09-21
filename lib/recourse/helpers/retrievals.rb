module Recourse
  module Helpers
    # The button that fetches a table's rows again from wherever they came.
    module Retrievals
    private

      # Offered where the routes said the rows may be fetched again and the page says
      # there is anything to fetch them from — an index of a CRM's work is no use to a
      # provider who has connected none, and only the host knows that.
      def retrieval_button
        return unless Recourse.retrievable?(controller.controller_path) && recourse_retrievable?

        button_to retrieval_path, class: 'btn btn-sm btn-solid theme-primary ms-3',
                                  form_class: 'd-inline-block',
                                  aria: { label: retrieval_label } do
          icon_tag :sync
        end
      end

      # The one route a retrievable resource earns, under the resource itself.
      def retrieval_path
        url_for controller: "/#{controller.controller_path}/retrievals", action: :create
      end

      def retrieval_label
        t 'recourse.retrieve', models: Recourse.model_title(resource_model,
                                                            lower: true)
      end
    end
  end
end
