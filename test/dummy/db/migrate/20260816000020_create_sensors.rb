class CreateSensors < ActiveRecord::Migration[8.1]
  # Two of them called `North gate` on purpose: a label short enough to type is not the
  # same as a label that says which row it means, and nothing in the schema promises it
  # does. A form still offers to type one, and a write that names both is refused.
  NAMES = ['North gate', 'North gate', 'South gate', 'Weir', 'Spillway'].freeze

  # The kind each one is, in the order the names above take. Two kinds and one table:
  # what a reading is filtered by when it is filtered by the sensor that took it.
  KINDS = %w[Sensor::Float Sensor::Radar Sensor::Float Sensor::Radar Sensor::Float].freeze

  def change
    create_table :sensors do |t|
      t.string :name, null: false
      t.string :type, null: false

      t.timestamps
    end

    add_reference :readings, :sensor, foreign_key: true

    up_only { connection.execute sensor_rows }
  end

private

  def sensor_rows
    values = NAMES.zip(KINDS).map do |name, kind|
      "('#{name}', '#{kind}', current_timestamp, current_timestamp)"
    end

    "insert into sensors (name, type, created_at, updated_at) values #{values.join ', '}"
  end
end
