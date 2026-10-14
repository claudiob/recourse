require 'test_helper'
require 'integration_case'

# What a table lists and which of its columns it draws: two defaults the gem picks
# and a host overrules — one on the model, one in a controller of its own.
class TestRecoursesScoping < IntegrationCase
  # The gem keeps the timestamps off every table by default, the way it does ciphertext
  # and the id; and a route the parent has no association for lists the whole model.
  # Each is a default, and the host is what answers for its own screens —
  # `recourse_displayed` on the model, and `recourse_relation` in the one controller
  # this app writes for itself.
  def test_a_host_may_widen_the_columns_and_narrow_the_rows
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    assert_includes body, 'data-cell="Created"'
    kept = Memo.where(person: Person.where(id: team.places.select(:person_id))).count

    assert_operator Memo.count, :>, kept
    assert_match(/of #{kept}\s*</, body)
  end

  # A record's own pages find it among the rows its table lists, so a memo reached under a
  # team that does not keep its person is not found, rather than read or edited there.
  def test_a_record_is_found_among_the_rows_its_table_lists
    team = Team.order(:id).second
    kept = Memo.where person: Person.where(id: team.places.select(:person_id))
    visit "/teams/#{team.id}/memos/#{kept.order(:id).first.id}/edit"

    left_out = Memo.where.not(id: kept).order(:id).first
    assert_raises ActiveRecord::RecordNotFound do
      @session.get "/teams/#{team.id}/memos/#{left_out.id}/edit"
    end
  end
end
