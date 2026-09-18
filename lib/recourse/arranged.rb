require 'active_support'

module Recourse
  # Keeps an arranged table numbered 1, 2, 3: a new row lands last among its own, and
  # the gap closes behind one that goes. Both are the gem's own screens' business. The
  # form it draws never asks for a position — a reader sets one by dragging a row, and
  # a box beside the handle would be a second way to say a thing already said — so a
  # column the schema insists on has to be filled from somewhere. And what a drop
  # reports is a row's place on the page, which means a position only while the two run
  # together: leave a hole and every later drag lands beside where it was aimed.
  #
  # Every model carries this, and it acts on the ones that keep a `position`. Nothing
  # to include and nothing to remember: the column is the declaration, so a table with
  # one is numbered whether its rows are ever dragged or only ever made in a console.
  # A host maintaining its own order says `def recourse_position = nil` and gets
  # neither callback. What it writes otherwise is `recourse_siblings`, and only where
  # more than one key could be the parent.
  module Arranged
    extend ActiveSupport::Concern

    included do
      before_validation :recourse_place_last, on: :create
      after_destroy :recourse_close_gap
    end

    # The rows this one's position is counted among: those under the same parent, or
    # the whole table where the model points nowhere. The parent is named rather than
    # its key, so a key that names no one table is answered by the record it holds and
    # the two halves are matched together.
    #
    # Override where two keys could be the parent and only one is: a picture belongs to
    # a department and to the file it shows, and its place is among the department's.
    def recourse_siblings
      name = recourse_position_reference
      return self.class.all unless name

      self.class.where name => public_send(name)
    end

  private

    # A model pointing one way is arranged within what it points at, and one pointing
    # nowhere is a whole table in one order. Which of several is the parent is the
    # model's to say: guessing would number a picture among every picture there is,
    # quietly and at the first write.
    def recourse_position_reference
      references = self.class.reflect_on_all_associations :belongs_to
      return if references.empty?
      raise Error, I18n.t('recourse.ambiguous_position', model: self.class.name) unless
        references.one?

      references.first.name
    end

    def recourse_place_last
      column = Recourse.position_column self.class
      return unless column && self[column].nil?

      self[column] = recourse_siblings.maximum(column).to_i + 1
    end

    def recourse_close_gap
      column = Recourse.position_column self.class
      return unless column

      Positioning.new(recourse_siblings, column).close self[column]
    end
  end
end

# Beside `Recoursive`'s own: a model is arranged by keeping the column, and there is no
# second place to say it again.
ActiveSupport.on_load :active_record do
  include Recourse::Arranged
end
