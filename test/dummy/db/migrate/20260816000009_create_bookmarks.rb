class CreateBookmarks < ActiveRecord::Migration[8.1]
  # The first person keeps two places, so a table has kept rows and unkept ones —
  # which is the whole of what a bookmark column has to draw. Neither is the first
  # place by id, so the kept-first order has something to move.
  KEPT_PLACES = [4, 7].freeze

  def change
    create_table :bookmarks do |t|
      # Whoever is looking. A dummy app has no session, so the host's own declaration
      # names a person rather than reading one off a request.
      t.references :person, null: false, foreign_key: true
      t.references :topic, polymorphic: true, null: false

      t.timestamps
    end

    add_index :bookmarks, %i[person_id topic_type topic_id], unique: true
    up_only { connection.execute bookmark_rows }
  end

private

  def bookmark_rows
    values = KEPT_PLACES.map do |place|
      "(#{Person.order(:id).first.id}, 'Place', #{place}, current_timestamp, current_timestamp)"
    end

    <<~SQL.squish
      insert into bookmarks (person_id, topic_type, topic_id, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
