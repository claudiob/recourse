# The four helpers this app writes for the gem to find.
module TabsHelper
  # A button the routes cannot name: a sweep counts what it is about to clear, and
  # only a team with places to clear is offered one.
  def recourse_extra_actions(record)
    return [] unless record.is_a?(Team) && record.places_count.to_i.positive?

    [["Sweep #{record.places_count} places", team_sweep_path(record), :post]]
  end

  # A tab the routes cannot name: the places in the ZIP where this person's first
  # one sits, which is a page under a ZIP rather than under a person. Conditional
  # too, since a person with no places has no such ZIP -- both of the things a
  # `nav_link_to` in a hand-written layout used to be there for.
  def recourse_extra_tabs(record)
    return [] unless record.is_a?(Person) && record.places.any?

    [['Neighbours', zip_places_path(record.places.first.zip)]]
  end

  # Two cells no column holds: a page this app builds from a route, and the month a date
  # falls in. The labels stand over every row of a table, so what a place has nothing to
  # say for is the value — never the label, or the columns would run crooked.
  def recourse_extra_columns(record)
    return {} unless record.is_a? Place

    { 'Nearby' => zip_places_url(record.zip), 'Opening' => record.opens_on&.strftime('%B') }
  end

  # And the way out of the sidebar, which no resource declares: a button, since
  # ending a session is never a GET.
  def recourse_extra_links
    [['Sign out', '/session', :delete]]
  end
end
