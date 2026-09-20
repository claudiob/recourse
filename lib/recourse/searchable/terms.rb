module Recourse
  module Searchable
    # What the search box above a table submits, and what it says while it is empty.
    module Terms
      # The predicate a search box submits: everything the model looks through at once,
      # joined by `or`. A host naming its own instead is taken whole, on every page the
      # model is read on.
      def search_field = Recourse.search_field(self)

      # What the search box says while it is empty, naming what it looks through. A
      # host's own words are taken whole here too.
      def search_prompt = Recourse.search_prompt(self)

      # What a search box looks through, and how it matches: the plaintext columns
      # and the labels behind foreign keys — less the one `except:` names — on
      # containment; or, for a model that keeps nothing in plaintext worth
      # searching, its encrypted columns, whole.
      # @api private
      def recourse_search_terms(except: nil)
        plain = recourse_searchable_columns + recourse_searchable_references(except:)
        return [plain, 'cont'] if plain.any?

        [recourse_encrypted_searchable_columns, 'eq']
      end

      # Those same terms as words, lower case but for the acronyms among them.
      # @api private
      def recourse_search_names(except: nil)
        fields, = recourse_search_terms(except:)

        fields.map { |field| Recourse.downcase recourse_term_name(field) }
      end

    private

      # A term is a column of this model, or a `zip_code` reaching through one of its
      # foreign keys — which a form and a table already have a name for.
      # @api private
      def recourse_term_name(field)
        reached = recourse_searchable_associations.find { |one| field.start_with? "#{one.name}_" }
        return reached.klass.recourse_reference_name if reached

        human_attribute_name field
      end
    end
  end
end
