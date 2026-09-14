require 'test_helper'
require 'integration_case'

# The two lines a host says about how every page looks.
class TestRecoursesColor < IntegrationCase
  # The dummy app asks for pink, and the page says so in the tokens every button,
  # link, sorted heading and focus ring reads. A typo would otherwise write
  # `var(--bs-purpel-500)` into every page and go unnoticed until somebody looked,
  # so a name the gem does not know is refused at the point it is set — and says
  # which names there are, rather than only that this one is wrong.
  def test_a_host_picks_a_primary_color_and_a_name_nobody_has_is_refused
    Recourse.color = :pink
    visit '/places'

    assert_includes body, '--bs-primary-base: var(--bs-pink-500);'
    # The ink a solid fill's label is drawn in, which the palette has a say in: white
    # on Dracula's pink reads 2.24:1 and its darkest neutral 5.32, so the label is dark
    # here and light under a palette whose pink is darker. Asserted rather than left to
    # coverage, since the line runs whichever of the two it returns — a page would stay
    # green while a button went illegible.
    assert_includes body, '--bs-primary-contrast: var(--bs-gray-975);'
    error = assert_raises(Recourse::Error) { Recourse.color = :purpel }

    assert_includes error.message, 'purpel'
    assert_includes error.message, 'purple'
  ensure
    Recourse.color = nil
  end

  # The dummy app asks for Dracula, so the page links its palette from the design site,
  # where every palette lives beside the stylesheet. A name nobody ships would otherwise
  # ask the browser for a stylesheet that is not there and go unnoticed until somebody
  # looked at a page, so it is refused where it is set.
  def test_a_host_picks_a_palette_and_a_name_nobody_ships_is_refused
    visit '/places'

    # Everything the page is styled and scripted by comes from the design site, where every
    # HouseAccount app draws from, and nothing is served by this gem any more.
    assert_includes body,
                    "<link rel='stylesheet' href='https://design.houseaccount.com/v0.3.1/css/houseaccount.css'>"
    assert_includes body,
                    "<script type='module' src='https://design.houseaccount.com/v0.3.1/js/houseaccount.js'>"
    refute_includes body, '/recourse/'
    # And the one thing these screens set that the house's stylesheet does not.
    assert_includes body, '--bs-body-font-family: helvetica, verdana, arial, sans-serif;'
    assert_includes body, '<link rel="stylesheet" ' \
                          'href="https://design.houseaccount.com/v0.3.1/theme/dracula.css" ' \
                          'data-recourse-theme="">'
    # The sidebar's toggle, and the attribute the palette link is found by: the two
    # halves of swapping a palette in the browser, and a rename either side of that
    # would leave a button that silently does nothing.
    assert_includes body, 'data-scheme-path-value="https://design.houseaccount.com/v0.3.1/theme"'
    # And the key the choice is kept under, which the layout's script reads back.
    assert_includes body, 'data-scheme-storage-value="recourse-scheme"'
    assert_includes body, "localStorage.getItem('recourse-scheme')"
    assert_includes body, "<i class='bi bi-moon-fill'></i>"
    assert_includes body, "<i class='bi bi-sun-fill'></i>"
    # Upstream's own palette is in the rotation too: a reader who cannot reach the one
    # the pages started in cannot undo a click.
    assert_includes body, '&quot;bootstrap&quot;'
    error = assert_raises(Recourse::Error) { Recourse.theme = :draculla }

    assert_includes error.message, 'draculla'
    assert_includes error.message, 'dracula'
  ensure
    Recourse.theme = :dracula
  end
end
