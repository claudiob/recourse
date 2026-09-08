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

  # Every rule the layout carries, in one bracket count. A stylesheet is inert text
  # until a browser parses it, so an unclosed comment takes every rule after it down
  # with it and no page here renders any differently — which is why this is asserted
  # rather than left to whichever test happens to look at the markup.
  def test_the_layout_ships_a_stylesheet_a_browser_can_parse
    visit '/places'

    styles = body.scan %r{<style>(.*?)</style>}m

    styles.flatten.each do |css|
      rules = css.gsub %r{/\*.*?\*/}m, ''

      refute_includes rules, '/*', 'a comment is opened and never closed'
      refute_includes rules, '*/', 'a comment is closed and never opened'
      assert_equal rules.count('{'), rules.count('}')
    end
  end

  # The dummy app asks for Dracula, so the page links its palette and the engine
  # serves it. The palette is a file rather than a block in the page, so what proves it
  # arrived is fetching it and finding Dracula's own paper. A name nobody ships would
  # otherwise ask the browser for a stylesheet that is not there and go unnoticed until
  # somebody looked at a page, so it is refused where it is set.
  def test_a_host_picks_a_palette_and_a_name_nobody_ships_is_refused
    visit '/places'

    assert_includes body,
                    '<link rel="stylesheet" href="/recourse/themes/dracula.css" ' \
                    'data-recourse-theme="">'
    # The sidebar's toggle, and the attribute the palette link is found by: the two
    # halves of swapping a palette in the browser, and a rename either side of that
    # would leave a button that silently does nothing.
    assert_includes body, 'data-scheme-path-value="/recourse/themes"'
    assert_includes body, "<i class='bi bi-moon-fill'></i>"
    assert_includes body, "<i class='bi bi-sun-fill'></i>"
    # Upstream's own palette is in the rotation too: a reader who cannot reach the one
    # the pages started in cannot undo a click.
    assert_includes body, '&quot;bootstrap&quot;'
    visit '/recourse/themes/dracula.css'

    assert_includes body, '--bs-white: #f8f8f2;'
    # And it declares nothing, because the eight work by overriding `:root` — so
    # dropping their block is the whole of what brings upstream's palette back.
    visit '/recourse/themes/bootstrap.css'

    refute_includes body, '--bs-'
    error = assert_raises(Recourse::Error) { Recourse.theme = :draculla }

    assert_includes error.message, 'draculla'
    assert_includes error.message, 'dracula'
  ensure
    Recourse.theme = :dracula
  end
end
