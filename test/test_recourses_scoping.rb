require 'test_helper'
require 'integration_case'

# What a table lists and which of its columns it draws: two defaults the gem picks
# and a host overrules — one on the model, one in a controller of its own.
class TestRecoursesScoping < IntegrationCase
  # The gem files a polymorphic type column with the machinery and keeps it off every
  # table, the way it does ciphertext and the id; and a route the parent has no
  # association for lists the whole model. Each is a default, and the host is what
  # answers for its own screens — `recourse_displayed` on the model, and
  # `recourse_relation` in the one controller this app writes for itself.
  def test_a_host_may_widen_the_columns_and_narrow_the_rows
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    assert_includes body, 'data-cell="About type"'
    kept = Memo.where(person: Person.where(id: team.places.select(:person_id))).count

    assert_operator Memo.count, :>, kept
    assert_includes body, "of #{kept} in total"
  end

  # A card carries what the routes can name. Anything else — a page filed under
  # another resource, a page a record only sometimes has — is the host's to add,
  # and `recourse_extra_tabs` is where it says so.
  def test_a_host_may_add_a_tab_no_route_names
    person = Person.order(:id).find { |one| one.places.any? }
    visit "/people/#{person.id}/places"

    assert_includes body, %(href="/zips/#{person.places.first.zip_id}/places">Neighbours</a>)
    # And which records get one is the host's to say: a place is not a person.
    visit "/places/#{person.places.first.id}"

    refute_includes body, 'Neighbours'
  end
end
