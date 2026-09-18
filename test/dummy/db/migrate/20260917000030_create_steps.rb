class CreateSteps < ActiveRecord::Migration[8.1]
  # What a team works through, four steps to a team: the table arranged within a
  # parent, and the one pointing two ways — so it is also what `recourse_siblings`
  # is for.
  STEPS = %w[Gather Assess Repair Report].freeze

  def change
    create_table :steps do |t|
      t.string :name, null: false
      # The parent a position is counted within, which the model has to name: nothing
      # can guess it from two keys.
      t.references :team, null: false, foreign_key: true
      # And whoever is to do it, which is the other one.
      t.references :person, null: false, foreign_key: true

      # Filled by the gem, a step's place among its team's steps.
      t.integer :position, null: false
      # And filled by the host, its place among the steps of whoever is to do them:
      # the second listing of one model, which the gem never maintains.
      t.integer :ranking, null: false

      t.timestamps
    end

    add_index :steps, %i[team_id position]
    add_index :steps, %i[person_id ranking]

    # Through the model, which is what fills both columns: neither is anybody's to
    # type, so neither is written here.
    up_only { create_steps }
  end

private

  def create_steps
    people = Person.ids

    Team.order(:id).each_with_index do |team, number|
      STEPS.each_with_index do |name, step|
        Step.create! name: name, team: team, person_id: people[(number + step) % people.size]
      end
    end
  end
end
