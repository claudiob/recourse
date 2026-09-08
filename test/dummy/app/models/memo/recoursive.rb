class Memo
  # Extends Memo with the four things it says for itself.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # Arranged within the person the memos are about, which is what a nested route
      # names — so `/people/1/memos` is a list somebody orders by hand, while
      # `/memos` reads every person's at once and is left to sort and search.
      def recourse_order = { position: :positionable }

      # A memo is written far more often than it is read, and a broadcast on every
      # one of them would redraw an index nobody is looking at.
      def recourse_broadcasts? = false

      # The kind of thing a memo is about, which the gem files with the machinery and
      # keeps off every table. Worth reading on this one: a memo about a place and a
      # memo about a person are different notes, and the id beside it says neither.
      def recourse_displayed = :about_type
    end
  end
end
