# Reopened for what a page counts, which a table, a heading and a tab all read here.
module Recourse
  # What a page counts, worked out once per class: a reload replaces the classes the
  # reflections belong to, so the engine empties this where it does.
  @counters = {}

  # The counts a model's pages draw, as `{ column => association }`. A column holding a
  # counter cache answers, read from the `belongs_to` where `counter_cache` is declared;
  # so does any `*_count` column named after an association the model has, which is how a
  # figure the app keeps itself -- a `has_many through`, which Rails will not cache -- is
  # counted like any other. A `*_count` column naming no association is a number and
  # nothing more, and one naming an association it does not count belongs under another
  # name: the heading and the link a counter draws would both say the wrong thing.
  # @param model [Class] the model the page is about.
  # @return [Hash{String => ActiveRecord::Reflection::AbstractReflection}] the counts.
  def self.counters(model)
    @counters[model.name] ||= cached_counters(model).merge counted_columns(model)
  end

  # Empties what was read off the reflections of classes a reload has replaced.
  # @return [Hash] the empty table.
  def self.forget_counters = @counters.clear

  private_class_method def self.cached_counters(model)
    model.reflect_on_all_associations(:has_many).filter_map do |association|
      column = association.inverse_of&.counter_cache_column
      [column, association] if column
    end.to_h
  end

  private_class_method def self.counted_columns(model)
    model.column_names.filter_map do |column|
      name = column.delete_suffix '_count'
      next if name == column

      association = model.reflect_on_association name
      [column, association] if association
    end.to_h
  end
end
