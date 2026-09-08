module Recourse
  module Helpers
    # What a foreign key is called, rather than the id that points at it.
    module Names
    private

      # The belongs_to a column is the foreign key of, of either kind: one this gem
      # can follow to a label, and one it can only read the class name of. Both name a
      # record, where the id alone is a number, so both are asked for together.
      def key_association(column)
        belongs_to_association(column) || polymorphic_association(column)
      end

      # The polymorphic belongs_to a column is the foreign key of, or nil when it is
      # not one. Every key at once and once per render, rather than a scan of the
      # model's associations for each cell of each row that holds one.
      def polymorphic_association(column)
        @recourse_polymorphs ||= resource_model.recourse_polymorphs

        @recourse_polymorphs[column]
      end

      # What one key says, whichever kind it is: the label of the record it points at
      # where it names a table, and the class name beside it where it names none.
      def named_cell(resource, association)
        return polymorphic_cell resource, association if association.polymorphic?

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

      # `Booking 12`. There is no label to read here — a key naming no one table has no
      # model to ask for one — but the column beside it keeps the class name, and a
      # kind and an id are between them the record that is meant, where the id on its
      # own is a number. Read off the attributes the row already carries rather than by
      # loading the record: naming it this way costs nothing, and loading one per row
      # to name it would cost a query per row.
      def polymorphic_cell(resource, association)
        kind = resource.attributes[association.foreign_type]
        return unless kind

        id = resource.attributes[association.foreign_key.to_s]

        led "#{kind} #{id}", kind, id
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
