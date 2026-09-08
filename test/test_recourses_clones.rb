require 'test_helper'
require 'integration_case'

# The way from a record to another one like it: a link on its own page, and the form
# that link opens already holding everything the record could lend.
class TestRecoursesClones < IntegrationCase
  # One pass over the whole feature: the link where the routes drew a form, the values
  # it carries into that form, and the one column it leaves for a reader to fill in.
  # `slug` is validated unique with no scope, so a copy of it could never be saved.
  def test_a_record_links_to_a_form_holding_everything_it_can_lend_but_its_unique_value
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    assert_includes body, %(<a class="btn theme-primary btn-sm btn-outline ms-3" \
href="/places/new?cloned_id=#{place.id}">Clone</a>)

    visit "/places/new?cloned_id=#{place.id}"

    assert_includes body, %(value="#{place.name}")
    assert_includes body, %(value="#{place.capacity}")
    # Encrypted, and read through `attributes`, so the form opens on the plaintext its
    # own edit page would have shown rather than on the ciphertext behind it.
    assert_includes body, %(value="#{place.secret}")
    refute_includes body, %(value="#{place.slug}")
    # And what no field above it can show: what the copy carries, named because nothing
    # else on the page says it is coming. One of a thing is named and several are
    # counted, and a file reads as what the record calls it rather than as a blob.
    assert_includes body, 'Its audit, its seal, and 2 photos will be copied too.'
  end

  # A place drawn from a form of its own says nothing about copying, since there is
  # nothing to copy -- which is what every ordinary `new` looks like.
  def test_an_ordinary_form_says_nothing_about_what_it_carries
    visit '/places/new'

    refute_includes body, 'will be copied too'
  end

  # And no link where there is no form to open: people are drawn `except: %i[new
  # create]`, so the routes are the whole answer, as they are for the Add link.
  def test_a_record_whose_resource_draws_no_form_offers_no_clone
    visit "/people/#{Person.order(:id).first.id}"

    refute_includes body, '>Clone</a>'
  end
end
