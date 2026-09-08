module Recourse
  module Helpers
    # The Add and Remove a listing of a many-to-many carries: every row of the far
    # side, and a button writing the join row between it and the record the page
    # hangs off.
    module Joins
    private

      # The join this page edits, or nil where the page only lists.
      def resource_join
        Recourse.join_of controller.controller_path
      end

      # The far-side ids already joined, read once for the page rather than a query
      # a row: a page is twenty rows and the answer is one integer column.
      def joined_ids
        @joined_ids ||= begin
          rows = resource_join.where join_key(resource_parent.class) => resource_parent.id

          rows.pluck(join_key(resource_model)).to_set
        end
      end

      # What the table's cache key carries for a join, and nil where there is none.
      # The rows are the far side's and never change when a join does, so without
      # this a fragment drawn before the last Add outlives it. The join's own name
      # leads, because an expanded key renders `nil` and `[]` as the same empty
      # string: without it a listing of every provider with nothing joined yet and
      # the plain index of the same providers share one fragment, and whichever drew
      # first decides whether the other has any buttons.
      def join_digest
        [resource_join.name, *joined_ids.to_a.sort] if resource_join
      end

      # Add where the two are not joined and Remove where they are — one button
      # either way, since the path names both records and neither needs submitting.
      def join_button(record)
        joined = joined_ids.include? record.id

        button_to t("recourse.#{joined ? 'remove' : 'attach'}"), join_url(record, joined),
                  method: joined ? :delete : :post, class: 'btn btn-sm btn-solid'
      end

      def join_url(record, joined)
        url_for controller: "/#{controller.controller_path}/#{resource_join.model_name.plural}",
                action: joined ? :destroy : :create,
                "#{resource_parent.model_name.singular}_id": resource_parent.id,
                "#{resource_model.model_name.singular}_id": record.id
      end

      # Which of the join's keys points at a model, asked of the join's own
      # `belongs_to` so a key named unusually needs nothing said about it.
      def join_key(model)
        resource_join.recourse_references.find { |one| one.klass == model }.foreign_key
      end
    end
  end
end
