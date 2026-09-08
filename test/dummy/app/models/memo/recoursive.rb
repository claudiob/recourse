class Memo
  # Extends Memo with the two things it says for itself.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # A memo is written far more often than it is read, and a broadcast on every
      # one of them would redraw an index nobody is looking at.
      def recourse_broadcasts? = false

      # When it was written, which the gem keeps off a table by default: a memo is a
      # note in a log, and when it was made is the first thing to know about one.
      def recourse_displayed = :created_at
    end
  end
end
