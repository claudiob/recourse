class StopDefaultingAPosition < ActiveRecord::Migration[8.1]
  # `default: 0` let a row be written with no position at all, which is exactly what a
  # host forgetting `Recourse::Arranged` does — and left the two tables that arrange
  # unable to prove the concern does anything. The column insists again.
  def change
    change_column_default :teams, :position, from: 0, to: nil
    change_column_default :memos, :position, from: 0, to: nil
  end
end
