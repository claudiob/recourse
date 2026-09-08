require 'test_helper'
require 'integration_case'

# A resource reached through a key that names no one table. Nothing in the path says
# which key it is — `/zips/1/notes`, never `/abouts/1/notes` — so what settles it is
# the parent's own half of the association.
class TestRecoursesPolymorphic < IntegrationCase
  def teardown
    Note.where(body: 'About a ZIP').destroy_all
  end

  # And where the key is drawn rather than answered by the address, it is the record
  # it points at and not the number pointing there. There is no label to read -- a key
  # naming no one table has no model to ask for one -- so the kind kept in the column
  # beside it and the id are read out together, which between them say which row is
  # meant. The kind is what an id alone leaves out, and the reason this is not simply
  # a number: memo 2 is about a ZIP and memo 3 about a place, and both say `1`.
  def test_a_polymorphic_key_reads_as_the_kind_it_points_at_and_the_id
    visit '/memos'
    drawn = body.scan(%r{data-cell="About"[^>]*>(.*?)</td>}m).flatten.map(&:strip)
    named = drawn.reject(&:empty?)
    every = Memo.all.map { |one| "#{one.about_type} #{one.about_id}" }

    named.each { |cell| assert_includes every, cell.gsub(/<[^>]*>/, '') }
    # A key pointing at nothing names nothing, and the last page is all such memos.
    visit '/memos?page=3'

    assert_includes body.scan(%r{data-cell="About"[^>]*>(.*?)</td>}m).flatten.map(&:strip), ''

    assert_includes named, 'ZIP 1'
  end

  # The rows a polymorphic key points at, and only those: the same page read under
  # the other ZIP is a different set, and the table holds more than the two of them
  # together. The key itself stays off the table, the way an ordinary parent's does
  # -- the address answered it, so a column would only repeat the address.
  def test_a_nested_index_over_a_polymorphic_key_is_the_parents_own_rows
    zip, other = ZIP.order(:id).first 2
    visit "/zips/#{zip.id}/notes"

    assert_equal zip.notes.count, body.scan('data-cell="Body"').size
    refute_includes body, 'data-cell="About"'
    visit "/zips/#{other.id}/notes"

    assert_equal other.notes.count, body.scan('data-cell="Body"').size

    assert_operator Note.count, :>, zip.notes.count + other.notes.count
  end

  # The form asks for what the path has not already answered, and the write puts the
  # class name beside the id — a key carrying one without the other points into every
  # table at once.
  def test_a_nested_form_never_asks_which_parent_and_the_write_says_which
    zip = ZIP.order(:id).first
    visit "/zips/#{zip.id}/notes/new"

    refute_includes body, 'name="note[about_id]"'
    assert_includes body, %(action="/zips/#{zip.id}/notes")
    @session.post "/zips/#{zip.id}/notes", params: { note: { body: 'About a ZIP' } }

    assert_equal 303, @session.response.status
    assert_equal zip, Note.find_by!(body: 'About a ZIP').about
  end

  # And a route the parent declares no half for is left exactly as it was: a page
  # gathered from several parents at once is nobody's one record, and the host's
  # `recourse_relation` is still what scopes it. Teams keep no memos, so the key
  # the model does carry is not quietly read as this nesting.
  def test_a_parent_that_declares_no_half_resolves_no_parent
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    # Still a column, where the ZIP's own page has none: nothing here took the key
    # for the parent the address names, so nothing hid it as already answered.
    assert_includes body, 'data-cell="About"'
    assert_empty Memo.where(about: team)
    refute_empty body.scan('data-cell="Body"')
  end
end
