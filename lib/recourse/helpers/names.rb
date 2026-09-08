module Recourse
  module Helpers
    # What a foreign key is called, rather than the id that points at it.
    module Names
    private

      # What one key says: the label of the record it points at, led to that record's
      # page where the routes drew one.
      def named_cell(resource, association)
        record = resource.association(association.name).reader

        record && led(reference_cell(resource, association), association.klass.name, record.id)
      end

      # The words of a cell, led to the record's own page where the routes drew one that
      # can be linked to. Here rather than inside `reference_cell`, which also fills a
      # form field's value -- an anchor inside an input is markup a reader would see
      # spelled out. A cell with nothing in it leads nowhere: there would be no words
      # to click.
      def led(said, kind, id)
        path = shown_resource kind
        return said if path.nil? || said.blank?

        turbo_link_to said, url_for(controller: "/#{path}", action: :show, id:)
      end

      # The resource a kind is read on, where the routes drew one that can be linked to
      # at all: declared at the top level, so no parent id is wanted that a row like
      # this has no way to supply; listing that model; and answering `show`. Nil where
      # any of the three is missing, which is a cell that reads as words rather than one
      # leading somewhere the router would refuse. Remembered per kind and per render:
      # a table asks this once a row, and no route is drawn while a page is drawing.
      def shown_resource(kind)
        @recourse_shown ||= {}
        return @recourse_shown[kind] if @recourse_shown.key? kind

        @recourse_shown[kind] = Recourse.declared.find do |path|
          Recourse.parent_of(path).nil? && Recourse.model?(path)&.name == kind &&
            routed?(path, 'show')
        end
      end
    end
  end
end
