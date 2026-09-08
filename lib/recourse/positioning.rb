module Recourse
  # Moves one row of an arranged table to a place in it, and closes the gap it leaves
  # by shifting whatever it displaced one step the other way.
  class Positioning
    # The rows a position is counted within, and the column it is counted in. A
    # relation rather than a model, because which rows those are is the route's answer
    # on a drag and the record's on a delete, and each caller has already asked.
    def initialize(relation, column)
      @relation = relation
      @column = column
    end

    # Puts the record at `position`, counting from one and never past the end — a drag
    # reports where a row was dropped, and a page is not the whole table. That the two
    # agree at all is what `Arranged` is for: a drop names a row's place on the page,
    # which is a position only while the table runs 1, 2, 3 with no gaps in it.
    def move(record, position)
      target = position.to_i.clamp 1, @relation.count
      current = record[@column]
      return if target == current

      @relation.transaction do
        displace record, current, target
        record.update! @column => target
      end
    end

    # Closes the gap a row left behind it: whatever stood after it moves one step up.
    # The row itself is already gone, so the block starts where it was standing.
    def close(from)
      @relation.where(@column => from..).update_all shift(-1)
    end

  private

    # Everything between where the row was and where it is going moves one step
    # towards the space it left: moving up, the block beneath it shifts down; moving
    # down, the block above it shifts up. That is what the two ranges say, the
    # half-open one compensating for the row itself being left out of the count.
    def displace(record, current, target)
      delta = current <=> target
      between = delta.positive? ? target...current : current..target

      @relation.excluding(record).where(@column => between).update_all shift(delta)
    end

    # One statement however many rows it moves, and it touches them in the same
    # breath: `update_all` runs no callbacks, so nothing else would tell the relation
    # a table caches on that its version has changed, and the old order would be
    # served straight back.
    def shift(delta)
      column = @relation.klass.connection.quote_column_name @column
      moved = "#{column} = #{column} + ?"

      return [moved, delta] unless @relation.klass.column_names.include? 'updated_at'

      ["#{moved}, updated_at = ?", delta, Time.current]
    end
  end
end
