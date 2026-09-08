module Recourse
  module Searchable
    # What a model's own schema offers a search: which of its columns are worth
    # looking through, and which of its foreign keys are worth looking past.
    module Columns
      # Column types a search box can match on containment. An enum is a Postgres
      # type of its own, and what it holds is a word, so it reads as a string too.
      SEARCHABLE_TYPES = %i[string text citext enum].freeze

      # Columns worth searching: the indexed strings a table also shows. An index is
      # the only signal a schema carries about which column identifies a row rather
      # than describes it, and a column no page draws is not one to search by — a row
      # would arrive with nothing on it explaining why. That is also what keeps a
      # `recourse_hidden` column out: hidden from every screen means hidden here.
      def recourse_searchable_columns
        recourse_indexed_strings - recourse_encrypted_names - Recourse.hidden_columns(self)
      end

      # The attributes Active Record Encryption holds, as column names.
      def recourse_encrypted_names
        Array(encrypted_attributes).map(&:to_s)
      end

      # Foreign keys a search reaches through rather than filters by: the ones whose
      # other model is too long to list, since a menu is only a control while every row
      # fits in one. The label has to be a word to match, and the key one a screen
      # draws -- a row matched through a hidden key arrives saying nothing about why.
      def recourse_searchable_associations
        hidden = Recourse.hidden_columns self

        recourse_references.select do |association|
          next false if hidden.include? association.foreign_key.to_s

          !association.klass.recourse_listable? && association.klass.recourse_searchable_label?
        end
      end

      # True where the label is a column a `cont` can match. Reaching through a foreign
      # key to compare an id or a date against typed text says nothing -- and neither
      # does naming a column Ransack will not answer to. Encryption leaves a column's
      # type alone, so a label the search could never match reads as a word here and is
      # caught by the allowlist instead: a term built from one raises on the reader the
      # box asks for, taking down every index that reaches this model through a key.
      def recourse_searchable_label?
        label = recourse_label.to_s

        SEARCHABLE_TYPES.include?(type_for_attribute(label).type) &&
          ransackable_attributes.include?(label)
      end

    private

      # The same columns where they are encrypted, which a search matches whole
      # rather than by containment: a LIKE reads ciphertext and matches nothing,
      # while a deterministic value encrypts to the same bytes every time, so `=`
      # still finds it. Rails' own `deterministic_encrypted_attributes` is that
      # list — a column encrypted any other way never compares equal twice.
      def recourse_encrypted_searchable_columns
        deterministic = Array(deterministic_encrypted_attributes).map(&:to_s)

        (recourse_indexed_strings & deterministic) -
          Recourse.hidden_columns(self)
      end

      # Every indexed column whose value is a word, whether or not it is encrypted.
      # Asked through `type_for_attribute` — the one door the whole gem uses — so
      # an `attribute` override counts here the way it counts on a form.
      def recourse_indexed_strings
        column_names.intersection(recourse_indexed_columns).select do |column|
          type = type_for_attribute column
          # An array column answers with its subtype's own name — `text[]` reads as
          # `:text` — and a LIKE against an array is SQL that never runs. A type
          # wrapping a subtype is a collection, not a word, so it stays out.
          SEARCHABLE_TYPES.include?(type.type) && !type.respond_to?(:subtype)
        end
      end

      # Those foreign keys as Ransack names them: `zip_code`, for the ZIP that
      # `/locations` asks to be typed rather than picked out of 40,965 options.
      # `except:` leaves out the one a nested route has already answered.
      def recourse_searchable_references(except: nil)
        (recourse_searchable_associations - [except]).map do |association|
          "#{association.name}_#{association.klass.recourse_label}"
        end
      end

      # Columns an index covers, the primary key among them. Read from the schema
      # cache, so asking costs nothing after the first look — and the gem's one
      # reach into that cache, whose spelling moves across Rails majors, is fenced
      # in this method so an upgrade edits one place.
      def recourse_indexed_columns
        indexes = connection_pool.schema_cache.indexes table_name
        # An expression index reports a string rather than a list of columns, and it
        # names no column an ORDER BY could use, so intersecting drops it.
        column_names.intersection [primary_key, *indexes.flat_map { |one| Array one.columns }]
      end
    end
  end
end
