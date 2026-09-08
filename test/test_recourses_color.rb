require 'test_helper'
require 'integration_case'

# The line a host says about how every page looks, and the one a reader has.
class TestRecoursesColor < IntegrationCase
  # The dummy app asks for orange, and the page says so in the tokens every button,
  # link, sorted heading and focus ring reads. A typo would otherwise write
  # `var(--bs-purpel-500)` into every page and go unnoticed until somebody looked,
  # so a name the gem does not know is refused at the point it is set — and says
  # which names there are, rather than only that this one is wrong.
  def test_a_host_picks_a_primary_color_and_a_name_nobody_has_is_refused
    visit '/places'

    assert_includes body, '--bs-primary-base: var(--bs-orange-500);'
    # The ink a solid fill's label is drawn in: white on orange-500 reads 2.90:1, under
    # the 3:1 a button's label owes, so the label is dark here and white on purple.
    # Asserted rather than left to coverage, since the line runs whichever of the two
    # it returns — a page would stay green while a button went illegible.
    assert_includes body, '--bs-primary-contrast: var(--bs-gray-975);'
    error = assert_raises(Recourse::Error) { Recourse.color = :purpel }

    assert_includes error.message, 'purpel'
    assert_includes error.message, 'purple'
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

  # The sidebar ends with the reader's own control: a moon while the page is light and
  # a sun while it is dark, both drawn since only CSS knows which mode a page nobody
  # has chosen for is in. The controller and the key it keeps the choice under are
  # asserted by name: a rename either side would leave a button that silently does
  # nothing, and the layout's script reading a key nobody writes.
  def test_the_reader_may_flip_the_page_between_light_and_dark
    visit '/places'

    assert_includes body, 'data-controller="scheme"'
    assert_includes body, 'data-scheme-storage-value="recourse-scheme"'
    assert_includes body, "localStorage.getItem('recourse-scheme')"
    assert_includes body, "<i class='bi bi-moon-fill'></i>"
    assert_includes body, "<i class='bi bi-sun-fill'></i>"
  end
end
