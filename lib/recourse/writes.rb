# Reopened for what a page is told about the write that brought it here.
module Recourse
  # The flash key naming the row a write just landed on. Data for the page rather than
  # a message for the reader, so `_flash` keeps it out of the loop that draws the rest:
  # every other key there becomes a toast, whoever invented it.
  WRITTEN = 'recourse_written'

  # The name a row goes by in the page it is drawn on, which a write reports itself by
  # and a square keeps its own row by. Read by a controller and by a view, which is why
  # it lives here rather than in either.
  #
  # Nothing at all for a row with no key, since nothing addresses one and so nothing
  # has to find one again. The key has to be asked for rather than the method: a host's
  # aggregate rows answer `to_key` with nil, and `dom_id` turns that into `new_week` —
  # the same name for every row on the page, which is worse than no name at all.
  def self.row_id(record)
    return unless record.respond_to?(:to_key) && record.to_key

    ActionView::RecordIdentifier.dom_id record
  end
end
