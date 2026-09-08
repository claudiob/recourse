# Reopened for what one record lends another.
module Recourse
  # What a new record takes from the one a reader is copying. Extended onto `Recourse`,
  # so each of these is `Recourse.something` wherever it is called from.
  module Cloning
    # Every value a form would offer for the record, less the ones no second row may
    # hold. Read through `attributes`, which decrypts, so a copied record opens with the
    # plaintext its own form would have shown.
    def clonable_attributes(record)
      record.attributes.slice(*clonable_columns(record.class))
    end

    # Which columns those are. `editable_columns` has already left out the id, the two
    # timestamps, the counters and the position, so what is left to rule out is a value
    # a second row could not be saved with.
    def clonable_columns(model)
      editable_columns(model).reject { |column| unique_column? model, column }
    end

    # What no copy may inherit, cleared on every record in the tree. The id needs no
    # rule of its own, `dup` having reset the primary key already.
    def reset_clone(copy)
      model = copy.class
      blanked = TIMESTAMPS + clearable_columns(model)

      copy.assign_attributes model.recourse_counters.keys.index_with(0)
                                  .merge(blanked.index_with(nil))
    end

    # And what only the record a reader asked to copy may not inherit: the place it
    # holds. That one lands among rows that are already there, where two cannot share a
    # slot, so its place is worked out at the write like any new row's.
    #
    # A copy deeper in the tree keeps the place it was in. Its siblings are the copies
    # beside it and nobody else, so the order they were put in is part of what was
    # copied -- and there would be nothing to work a new place out from anyway, the
    # rows a position counts among hanging off a parent that is not written yet: every
    # one of them would measure the same empty scope and come back first.
    def reset_position(copy)
      copy.assign_attributes position_columns(copy.class).index_with(nil)
    end

  private

    # The unique columns of a record being copied wholesale, which is a wider question
    # than the form's: `clonable_columns` starts from what a reader may set, and `dup`
    # copies every column there is.
    def clearable_columns(model)
      model.column_names.select { |column| unique_column? model, column }
    end

    # Asked of the validators rather than of the indexes, and under both names a key
    # goes by — the association validates the record, the column the number pointing at
    # it — which is the same pair a field asks about when it asks whether it is required.
    def unique_column?(model, column)
      validators = validated_names(column).flat_map { |name| model.validators_on name }

      validators.any? { |one| unscoped_uniqueness? one }
    end

    # And only where the rule stands alone. What makes a scoped pair unique is the scope,
    # which the reader is free to change, so the value is copied and the form says so
    # when it is refused; an unscoped one could never be saved twice, so it opens empty.
    def unscoped_uniqueness?(validator)
      validator.is_a?(ActiveRecord::Validations::UniquenessValidator) &&
        validator.options[:scope].blank?
    end
  end

  extend Cloning
end
