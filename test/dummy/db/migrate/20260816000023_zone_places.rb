class ZonePlaces < ActiveRecord::Migration[8.1]
  # Where each of the first few places keeps its hours. A string column beside `status`
  # and `slug`, which is the point: what earns it a menu of every zone Rails knows is
  # the type its attribute reports, and the two beside it get a box.
  ZONES = ['Eastern Time (US & Canada)', 'Pacific Time (US & Canada)', 'Arizona'].freeze

  def change
    add_column :places, :time_zone, :string

    up_only { ZONES.each_with_index { |zone, place| connection.execute zoned(zone, place) } }
  end

private

  def zoned(zone, place)
    <<~SQL.squish
      update places set time_zone = '#{zone}'
      where id = (select id from places order by id limit 1 offset #{place})
    SQL
  end
end
