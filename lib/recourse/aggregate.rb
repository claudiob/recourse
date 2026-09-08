require 'active_support'

module Recourse
  # A resource with no rows of its own: a page assembled out of other models' records —
  # the messages a conversation comes to, a digest of a week — which the gem asks the
  # same questions as a table. Everything a table answers from its columns and its
  # associations is answered here as the nothing an aggregate has, so a host writing one
  # includes this and says only what its own is called and drawn with.
  #
  # A concern rather than a module to extend, so a class says `include Recourse::Aggregate`
  # once: the class methods arrive with it, and so does the naming a gem needs to title a
  # class that has no table to read a name from.
  module Aggregate
    extend ActiveSupport::Concern

    included do
      # `model_name` is what every title, crumb and tab reads a resource's word from,
      # and a class with no table has nowhere else to get one.
      extend ActiveModel::Naming
    end

    class_methods do
      # No columns, so no cell, no field and no value: what such a page draws is the
      # host's own template, and there is nothing here for the gem to lay out.
      def column_names = []

      # And so none of the kinds a column comes in.
      def defined_enums = {}

      # And no key, a key being what names a row.
      def primary_key = nil

      # Nothing encrypted, so nothing to mask and nothing to keep off a table.
      def recourse_encrypted_names = []

      # Nothing to sort by, so no heading of one is a link.
      def ransortable_attributes(_auth_object = nil) = []

      # Nothing to look through, so no box above it.
      def recourse_searchable_columns = []

      # Nor through an association, there being none to reach along.
      def recourse_searchable_associations = []

      # Nothing commits, so nothing broadcasts, so no index of one opens a socket to
      # listen for a change that cannot arrive.
      def recourse_broadcasting? = false

      # Nothing to keep off a screen that draws none of it.
      def recourse_hidden = []

      # And nothing to say about a column there is none of.
      def recourse_comment(_column) = nil

      # And nothing to put back on one.
      def recourse_displayed = []

      # No counter cache, there being no association to count and no column to hold it.
      def recourse_counters = {}

      # No column reserved for single table inheritance: there is no table to reserve
      # one in, and no subclass to be filed under it.
      def inheritance_column = nil

      # No key to follow: a key points at a row, and an aggregate keeps none — so
      # nothing to label, to list, to filter by or to eager-load.
      def recourse_references = []

      # Nor an association of any other shape, which is asked for more widely than
      # those keys are: a bookmark is looked for along a `has_many`, and a generator
      # asks what rows could be counted through one.
      def reflect_on_all_associations(*) = []

      # And no polymorphic key either, for the same reason.
      def recourse_reference_types = []

      # Nothing to look through, which is what leaves such a page without a search box:
      # `Searchable` is extended onto Active Record, and an aggregate is not one, so the
      # question reaches here instead of going unanswered.
      def search_field(**) = nil

      # And so nothing for a box there is none of to say while it is empty.
      def search_prompt(**) = nil

      # And no filters beside it: those are drawn from enums, booleans and foreign
      # keys, which are three kinds of column an aggregate has none of.
      def filter_fields = {}

      # What names one of its rows, defaulted the way a model's is so that including
      # this is enough on its own.
      def recourse_label = :name

      # And what it is drawn with, which Unicon reads off the class's own name.
      def recourse_icon = model_name.singular.to_sym
    end
  end
end
