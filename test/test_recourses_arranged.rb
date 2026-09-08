require 'test_helper'
require 'integration_case'

# Keeping an arranged table numbered 1, 2, 3 — which is what makes a drop mean
# anything, since what one reports is a row's place on the page rather than a value.
# Nothing below includes anything to get it: a model saying `:positionable` in its
# `recourse_order` has said this too, and every model carries the callbacks that read
# that and do nothing where it is not said.
class TestRecoursesArranged < IntegrationCase
  # A model that points two ways and has not said which of them arranges it. Made here
  # rather than in the app, since what it is for is to be refused.
  class Unsaid < ActiveRecord::Base
    self.table_name = 'memos'

    belongs_to :person, optional: true
    belongs_to :about, polymorphic: true, optional: true

    def self.recourse_order = { position: :positionable }
  end

  def teardown
    Note.where(body: 'Added').destroy_all
    Memo.where(body: 'Added').destroy_all
    Team.where(name: 'Added').destroy_all
    Note.order(:id).group_by(&:about_id).each_value do |notes|
      notes.each_with_index { |note, index| note.update_column :position, index + 1 }
    end
  end

  # The form the gem draws never asks for a position, so a row written through it
  # arrives with none — and the column the schema insists on has to be filled from
  # somewhere. Last among its own parent's rows, which is where a reader looking at
  # the page would expect the one they just added.
  def test_a_new_row_lands_last_among_its_own_parents
    zip = ZIP.order(:id).first
    last = zip.notes.maximum :position

    note = zip.notes.create! body: 'Added'

    assert_equal last + 1, note.position
    # And not last in the table, which holds rows numbered higher under other parents.
    assert_operator Note.maximum(:position), :>=, note.position
  end

  # A table nothing points away from is one arrangement, so the whole of it is what a
  # new row lands at the end of.
  def test_a_new_row_of_a_flat_table_lands_last_in_it
    team = Team.create! name: 'Added'

    assert_equal Team.count, team.position
  end

  # The delete button the gem draws would otherwise leave a hole, and the rows below
  # it holding numbers that no longer say which row they are.
  def test_deleting_a_row_closes_the_gap_behind_it
    zip = ZIP.order(:id).fourth
    added = Array.new(3) { zip.notes.create! body: 'Added' }
    elsewhere = Note.where.not(about: zip).order(:id).pluck :id, :position

    added.second.destroy!

    assert_equal [1, 2], zip.notes.order(:position).pluck(:position)
    assert_equal elsewhere, Note.where.not(about: zip).order(:id).pluck(:id, :position)
  end

  # Where two keys could be the parent, the model is what says which — and is obeyed
  # over anything worked out here. A memo is ordered among one person's, whatever it
  # happens to be about.
  def test_a_model_that_names_its_own_rows_is_obeyed
    person = Person.order(:id).first
    last = Memo.where(person: person).maximum :position

    memo = Memo.create! person: person, about: ZIP.order(:id).first, body: 'Added'

    assert_equal last + 1, memo.position
  end

  # And where it has not said, it is told so rather than quietly numbered among every
  # row in the table — which is a corruption nothing on a page would report.
  def test_a_model_pointing_two_ways_is_asked_which_one_arranges
    error = assert_raises Recourse::Error do
      Unsaid.new(body: 'x').recourse_siblings
    end

    assert_includes error.message, 'Unsaid'
    assert_includes error.message, 'recourse_siblings'
  end
end
