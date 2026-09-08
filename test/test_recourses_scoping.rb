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
end
