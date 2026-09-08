class Note
  # Extends Note with the order its rows are read in.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # Arranged within whatever the note is about, which is what a nested route names.
      def recourse_order = { position: :positionable }
    end
  end
end
