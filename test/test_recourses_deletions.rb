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
end
