require 'active_support'

module Recourse
  # Extends every Active Record model, so each one says how it is labelled, which
  # of its columns a screen draws, what its index eager-loads and how it is sorted.
  module Recoursive
    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name

    # The concept a resource is drawn with, which Unicon names in each icon set it
    # knows. A model's own name by default — `contact` draws a rolodex, `job` a hammer
    # — and Unicon answers with a circle for a name it has never heard of.
    def recourse_icon = model_name.singular.to_sym

    # Columns the model keeps off its screens — the table, the show page, the
    # form and the search box — none by default. One name or a list:
    # `def recourse_hidden = :name` reads as well as `%i[name title]`.
    def recourse_hidden = []

    # And the columns a table draws whatever would otherwise keep them off it —
    # ciphertext, the id, the inheritance column, and the two
    # timestamps. Every one of those is a default the gem picks, and a host is what
    # answers for its own screens: `def recourse_displayed = :phone` puts a number
    # back on a table that recognises its rows by nothing else, and
    # `%i[created_at updated_at]` asks for the two Rails keeps rather than the two
    # a record is about. A timestamp named here still lands last, and in that order,
    # whichever way round it was written.
    def recourse_displayed = []

    # `ZIP code`: what to call a foreign key pointing here. A form's label, a table's
    # heading and a search prompt all name the same thing, so they name it once.
    def recourse_reference_name
      attribute = Recourse.downcase human_attribute_name(recourse_label)

      I18n.t 'recourse.reference', model: model_name.human, attribute: attribute
    end

    # True when the label has a length, so it is short enough to be typed and a
    # form can ask for the value instead of listing every record to pick from.
    def recourse_typed_label?
      validators_on(recourse_label).any? ActiveModel::Validations::LengthValidator
    end

    # The belongs_to associations this gem can follow. A polymorphic key names no
    # one table, so nothing can label it, list it, filter by it or search through
    # it — its column reads and edits as the number it holds, like any other.
    def recourse_references = reflect_on_all_associations(:belongs_to).reject(&:polymorphic?)

    # Associations the index eager-loads, in any shape `includes` accepts. Every
    # belongs_to it can follow, since each cell naming one would be a query of its own.
    def recourse_includes = recourse_references.map(&:name)

    # The column this model's rows are positioned by — dragged into an order somebody
    # chose rather than sorted into one — or nil for a table nobody positions. The
    # column is the whole of the declaration, so a model keeping a `position` has said
    # this already and says nothing here.
    #
    # Overridden two ways. `def recourse_position = :ordering` where the column is
    # named otherwise, and `def recourse_position = nil` where a host keeps the order
    # itself: that one is the way out of the convention, and it takes the handle off
    # the table and both callbacks off the model together.
    def recourse_position
      Recourse::POSITION_COLUMN if Recourse.positionable? self
    end

    # How the index sorts its rows, in any shape `order` accepts. The column it is
    # positioned by where there is one — the order a table is read in and the order
    # somebody put it in are one fact, and a table read in another order would have a
    # drop reporting a place that is no position at all — and by id otherwise, which is
    # the one column every table has and the order rows were created in.
    def recourse_order = recourse_position&.to_sym || :id

    # What a column is for, said where the table itself documents it — a form draws it
    # under the field that sets it. Read from the schema, which is the one thing here no
    # validator can answer: a comment has nothing to disagree with. Nil where the schema
    # says nothing, and nil on every adapter that keeps no comments at all — SQLite is
    # one — which is why a host may answer it instead.
    def recourse_comment(column) = columns_hash[column]&.comment
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Recoursive
end
