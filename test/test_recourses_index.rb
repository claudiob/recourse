require 'test_helper'
require 'integration_case'

# The table `recourses` draws, and the chrome around it.
class TestRecoursesIndex < IntegrationCase
  # One pass over a page carrying every kind of column: a heading that sorts and one
  # that does not, a counter headed by what it counts, a foreign key read as a label,
  # and the columns no table shows — the id, the ciphertext, the readonly and the
  # hidden. A `data-cell` carries the title as text, so a narrow screen labels the
  # cell with a word rather than with a link.
  def test_the_table_shows_every_column_that_earns_a_place_and_no_other
    visit '/places'

    assert_includes body, 'href="/places?q%5Bs%5D=name+asc">Name</a></th>'
    # Indexed, so it sorts; `Capacity` is not, so it is a heading and nothing more.
    assert_includes body, '<th scope="col">Capacity</th>'
    assert_includes body, '<td data-cell="Team">Blue Crew</td>'
    # Its own status, as the word the column holds rather than a number.
    assert_includes body, '<td data-cell="Status"><span class="badge">draft</span></td>'
    # A list is counted rather than drawn: the values belong to the record's own page,
    # and a column of them inside a column of them is not a table.
    assert_includes body, '<td data-cell="Tags">3 items</td>'
    # `Details` among them: a JSON payload is one value as wide as the page, so no
    # table draws one until a model names it back with `recourse_displayed`.
    %w[Id Secret Notes Webhook Details].each do |column|
      refute_includes body, %(data-cell="#{column}")
    end
    # The whole row, in the bands a column's kind puts it in: the squares and the links
    # that open the record, then what state it is in, whose it is, what it says, its
    # flags, the long ones, when it happened, and the two Rails keeps. A place counts
    # nothing, so the band past those is empty here — `/people` is where it is read.
    # Inside a band the order is the table's own, which is what leaves `capacity rating
    # area` reading as the schema wrote it. Asserted whole, so a band moving is a
    # failure rather than a surprise noticed on a page.
    headings = body.scan(/data-cell="([^"]+)"/).flatten.uniq

    assert_equal [
      'Bookmark', 'Show', 'Edit', 'Status', 'ZIP', 'Team', 'Person', 'Name', 'Slug',
      'Capacity', 'Rating', 'Area', 'Hourly rate', 'Commission rate', 'Phone', 'Website',
      'Busiest month', 'Founded year', 'Time zone', 'Active', 'Verified', 'About', 'Tags',
      'Opens on',
      'Audited at', 'Created at', 'Updated at',
      # Two a host added, which stand last and carry no sort link: they are cells rather
      # than columns, and there is nothing for a heading to order the rows by.
      'Nearby', 'Opening',
    ], headings
    # `ZIP` and not `ZIP code`, which is the word the form asks with: a heading stands
    # over what a record is called, and nothing is typed under one.
    refute_includes headings, 'ZIP code'
  end

  # A counter draws both ways it can be read, and the stylesheet is what picks: the
  # icon of what it counts beside the word itself, over a figure the counted model's
  # own plural follows. Named for a reader who cannot see the icon, and sorting; its
  # cells link out of the frame to the index nested under that row — and each says
  # what it counts twice over besides, in a label for the reader who would otherwise
  # hear only `3`, and in a tooltip on the bare figure alone. Both forms of the count
  # are in the markup and a stylesheet shows one, which is what lets that tooltip
  # ride on the figure and keep quiet beside the phrase that already says the word.
  # It closes the row, which the whole heading list is what pins: a person's own name
  # is read before what they gathered.
  def test_a_counter_column_is_an_icon_and_a_word_over_a_figure_that_links
    person = Person.order(:id).first
    visit '/people'
    icon = '<i class="bi bi-building recourse-counter-icon" aria-label="Places" ' \
           'role="img" data-controller="tooltip" data-bs-placement="top" ' \
           'data-bs-title="Places"></i><span class="recourse-counter-word">Places</span>'
    figure = '<span class="recourse-counter-figure" data-controller="tooltip" ' \
             'data-bs-placement="top" data-bs-title="Places">3</span>'
    word = '<span class="recourse-counter-word">3 places</span>'

    cell = %(<a aria-label="3 Places" data-turbo-frame="_top" href="/people/#{person.id}/places">)

    assert_includes body, %(q%5Bs%5D=places_count+asc">#{icon}</a></th>)
    assert_includes body, "#{cell}#{figure}#{word}</a>"
    assert_equal %w[Show Edit Name Places], body.scan(/data-cell="([^"]+)"/).flatten.uniq
  end

  # A sidebar link answers to a letter of its own title, and the first one free:
  # Places and People both start with P, and Places is declared first. The icon
  # beside each is the concept its model names — nothing says the word `Memos`
  # draws a sticky, the model's own name does.
  def test_each_sidebar_entry_marks_the_letter_that_reaches_it
    visit '/places'

    assert_includes body, '<span class="recourse-key">P</span>laces'
    assert_includes body, 'P<span class="recourse-key">e</span>ople'
    # Declared outside the module, and linking where its own routes were drawn.
    assert_includes body, 'href="/memos"'
    # An acronym keeps its capitals in a title the gem pluralized itself.
    assert_includes body, '<span class="recourse-key">Z</span>IPs'
  end
end
