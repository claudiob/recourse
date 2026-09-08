class CreateSensors < ActiveRecord::Migration[8.1]
  # Two of them called `North gate` on purpose: a label short enough to type is not the
  # same as a label that says which row it means, and nothing in the schema promises it
  # does. A form still offers to type one, and a write that names both is refused.
  NAMES = ['North gate', 'North gate', 'South gate', 'Weir', 'Spillway'].freeze

  def change
    create_table :sensors do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_reference :readings, :sensor, foreign_key: true

    up_only { connection.execute sensor_rows }
  end

private

  def sensor_rows
    values = NAMES.map { |name| "('#{name}', current_timestamp, current_timestamp)" }

    "insert into sensors (name, created_at, updated_at) values #{values.join ', '}"
  end
end
