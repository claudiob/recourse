class CreateTeams < ActiveRecord::Migration[8.1]
  # Four of them, well under MENU_LIMIT, so a foreign key pointing here is picked
  # from a menu — the other half of what the ZIPs table proves. The fourth is given
  # no places on purpose: a filter menu counts what each option would narrow to and
  # hides the ones that would narrow to nothing, so this is the row that proves
  # `All …` has something to reveal.
  TEAMS = ['Blue Crew', 'Green Watch', 'Red Shift', 'Night Shift'].freeze

  def change
    create_table :teams do |t|
      t.string :name, null: false
      # Named like an identifier, which is what a seed reads to know it holds
      # digits rather than words.
      t.string :uid
      t.integer :places_count, null: false, default: 0

      t.timestamps
    end

    add_index :teams, :name, unique: true

    up_only { TEAMS.each { |name| connection.execute team_row(name) } }
  end

private

  def team_row(name)
    <<~SQL.squish
      insert into teams (name, uid, places_count, created_at, updated_at)
      values ('#{name}', '#{format '%06d', TEAMS.index(name) + 1}', 0,
              current_timestamp, current_timestamp)
    SQL
  end
end
