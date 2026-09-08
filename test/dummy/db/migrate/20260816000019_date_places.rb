class DatePlaces < ActiveRecord::Migration[8.1]
  # Two numbers a place keeps that are not quantities: the month it is busiest in and
  # the year it opened. Small integers like `capacity` beside them, which is the point —
  # what tells the three apart on a page is the type each attribute reports, never the
  # name of the column or the kind the database keeps it in.
  def change
    add_column :places, :busiest_month, :integer, limit: 2
    add_column :places, :founded_year, :integer, limit: 2

    up_only { connection.execute months_and_years }
  end

private

  def months_and_years
    <<~SQL.squish
      update places set busiest_month = 1 + (id % 12), founded_year = 1990 + (id % 30)
    SQL
  end
end
