# Reopened for the calendar a table of events can be read as.
module Recourse
  # The column an event opens at, which is the day and the hour a calendar draws it on.
  START_COLUMN = 'starts_at'

  # And the one it closes at, which is how far down the day it reaches.
  FINISH_COLUMN = 'ends_at'

  # The two together, which is what a model is asked for its rows to be a week's events.
  EVENT_COLUMNS = [START_COLUMN, FINISH_COLUMN].freeze

  # The day a week opens on. Sunday, which is the column a calendar leads with wherever
  # these pages are read — `Date.beginning_of_week` is the host's own setting, and a
  # grid of seven is not a thing to draw two ways.
  WEEK_START = :sunday

  # Whether a model's rows can be drawn on a calendar: both ends of an event, and both
  # an instant rather than a day — a date has no hour for a week to place it by. Asked
  # of the type the model reports, so an `attribute` override counts and a column of
  # another kind named `starts_at` earns nothing.
  def self.calendarable?(model)
    EVENT_COLUMNS.all? { |column| model.type_for_attribute(column).type == :datetime }
  end

  # The Sunday a day belongs to, which is the week a calendar of it opens on.
  def self.week_of(day) = day.beginning_of_week WEEK_START
end
