require 'test_helper'
require 'integration_case'

# What a delete says before it goes ahead, and that it then goes ahead.
class TestRecoursesDeletions < IntegrationCase
  def teardown
    Place.where(slug: 'kips-place').destroy_all
    Memo.where(body: 'About Kip').destroy_all
    Person.where(name: 'Kip').destroy_all
  end

  # Deleting names what goes with it before it goes, counted one level down: the
  # children that go too, and the ones that are only let go of.
  def test_destroy_warns_by_name_and_count_then_removes_the_row
    person = Person.create! name: 'Kip', email: 'kip@example.com'
    person.memos.create! body: 'About Kip'
    person.places.create! zip: ZIP.order(:id).first, team: Team.order(:id).first,
                          name: 'Kips place', slug: 'kips-place', capacity: 4, active: true
    visit "/people/#{person.id}/edit"
    warning = CGI.unescape_html body[/data-turbo-confirm="([^"]*)"/, 1]

    assert_includes warning, 'Delete Kip?'
    # Counted one level down, each side reading as what its `dependent:` does, and
    # each in the number it is: one place, one memo.
    assert_includes warning, '1 place will be deleted with it.'
    assert_includes warning, '1 memo will be kept, without its person.'
    assert_includes warning, 'Anything under those goes too.'
    assert_includes warning, 'This cannot be undone.'
    @session.delete "/people/#{person.id}"

    assert_equal 303, @session.response.status
    refute Person.exists?(person.id)
  end

  # A record's own page carries the button, whichever of its two pages is open: a
  # resource routed to be read and deleted but never changed is deleted from the page
  # that reads it. A nested index wears the parent's card and offers nothing of the kind.
  def test_a_record_is_deleted_from_whichever_of_its_own_pages_is_open
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    assert_includes body, 'Delete place'
    warning = CGI.unescape_html body[/data-turbo-confirm="([^"]*)"/, 1]

    assert_includes warning, "Delete #{place.name}?"
    visit "/people/#{Person.order(:id).first.id}/places"

    refute_includes body, 'Delete person'
  end

  # A model may refuse to give a row up, and the page says so where the row still is
  # rather than raising: the delete is answered like any other write that did not take.
  def test_a_row_a_model_will_not_give_up_says_so_and_stays
    team = Team.find_by! name: 'Night Shift'
    @session.delete "/teams/#{team.id}"

    assert_equal 303, @session.response.status
    assert Team.exists?(team.id)
    follow_and_assert_flash 'Team could not be deleted.'
  end

  # The button that deletes a row leaves the frame the table is drawn in. What the delete
  # lands on is the index again with a message over it, and the message is drawn outside
  # that frame -- so answering inside it would take the row away and say nothing.
  def test_the_button_deleting_a_row_answers_outside_the_tables_frame
    place = Place.joins(:photos_attachments).order(:id).first
    visit "/places/#{place.id}/photos"
    form = body[%r{<form[^>]*class="button_to"[^>]*action="[^"]*/photos/\d+"[^>]*>}]

    assert_includes form, 'data-turbo-frame="_top"'
  end

  # A model that undoes something rather than deleting it says so under its own name in
  # the host's locale, and the button and the dialog over it read alike. Every other
  # model is untouched: the one word the gem has is what they fall through to.
  def test_a_model_may_word_its_own_deletion
    visit "/memos/#{Memo.order(:id).first.id}/edit"
    warning = CGI.unescape_html body[/data-turbo-confirm="([^"]*)"/, 1]

    assert_includes body, 'Withdraw memo'
    refute_includes body, 'Delete memo'
    # A memo answers to no label column, so the heading names what it is, as it would
    # under the gem's own word.
    assert_includes warning, 'Withdraw Memo?'
    assert_includes warning, 'This cannot be undone.'
    # And a model that said nothing keeps the one word the gem has.
    visit "/places/#{Place.order(:id).first.id}"

    assert_includes body, 'Delete place'
  end
end
