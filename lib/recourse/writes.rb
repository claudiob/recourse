# Reopened for what a page is told about the write that brought it here.
module Recourse
  # The flash key naming the row a write just landed on. Data for the page rather than
  # a message for the reader, so `_flash` keeps it out of the loop that draws the rest:
  # every other key there becomes a toast, whoever invented it.
  WRITTEN = 'recourse_written'

  # The name a row goes by in the page it is drawn on, which a write reports itself by
  # and a square keeps its own row by. Read by a controller and by a view, which is why
  # it lives here rather than in either.
  def self.row_id(record) = ActionView::RecordIdentifier.dom_id(record)
end
