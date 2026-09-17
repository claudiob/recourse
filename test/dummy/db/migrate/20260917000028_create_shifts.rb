class CreateShifts < ActiveRecord::Migration[8.1]
  # Three weeks around the day this app's database was made, so the calendar opens on
  # a week with rows in it and the weeks either side have their own to move to.
  DAYS = (-10..10)

  # What a day holds: the hour a shift opens at, how many hours it runs, and what it is
  # called. The third overlaps the second, which is what makes a day draw two lanes.
  SHIFTS = [
    [9, 3, 'Morning shift'],
    [13, 4, 'Afternoon shift'],
    [15, 2, 'Handover'],
  ].freeze

  def change
    create_table :shifts do |t|
      t.string :name, null: false
      t.references :person, null: false, foreign_key: true

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end

    add_index :shifts, :starts_at

    up_only { DAYS.each { |day| create_shifts day } }
  end

private

  # Two shifts on every day and the third on every third, so a week holds a pair that
  # overlap as well as days that stack one clear of the other.
  def create_shifts(day)
    opening = (Time.zone.today + day).in_time_zone
    people = Person.ids

    SHIFTS.take((day % 3).zero? ? 3 : 2).each_with_index do |(hour, hours, name), number|
      Shift.create! name: name, person_id: people[(day + number) % people.size],
                    starts_at: opening + hour.hours, ends_at: opening + (hour + hours).hours
    end
  end
end
