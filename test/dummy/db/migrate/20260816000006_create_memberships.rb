class CreateMemberships < ActiveRecord::Migration[8.1]
  # A person joins the first two teams, so a page listing every team has some rows
  # joined and some not — which is the whole of what a join editor has to draw.
  TEAMS_PER_PERSON = 2

  def change
    create_table :memberships do |t|
      t.references :person, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    add_index :memberships, %i[person_id team_id], unique: true
    up_only { connection.execute membership_rows }
  end

private

  def membership_rows
    values = (1..Person.count).flat_map do |person|
      (1..TEAMS_PER_PERSON).map do |team|
        "(#{person}, #{team}, current_timestamp, current_timestamp)"
      end
    end

    <<~SQL.squish
      insert into memberships (person_id, team_id, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
