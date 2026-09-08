module Recourse
  module Searchable
    # What the search box above a table submits, and what it says while it is empty.
    module Terms
      # The predicate a search box submits: everything it looks through at once,
      # joined by `or`. Nil where a model has nothing worth looking through, which
      # is also what leaves that model's index without the form — filters and all.
      # `except:` takes the association a nested route already answered, so a page
      # pinned to one provider offers no box to search them all.
      def search_field(except: nil)
        fields, predicate = recourse_search_terms(except:)
        return if fields.empty?

        "#{fields.join '_or_'}_#{predicate}"
      end

      # What the search box says while it is empty, naming what it looks through.
      def search_prompt(except: nil)
        fields, predicate = recourse_search_terms(except:)
        return if fields.empty?

        list = recourse_search_names(except:).join ' or '
        I18n.t "recourse.searched_#{predicate}", list: list
      end

    private

      # What a search box looks through, and how it matches: the plaintext columns
      # and the labels behind foreign keys — less the one `except:` names — on
      # containment; or, for a model that keeps nothing in plaintext worth
      # searching, its encrypted columns, whole.
      def recourse_search_terms(except: nil)
        plain = recourse_searchable_columns + recourse_searchable_references(except:)
        return [plain, 'cont'] if plain.any?

        [recourse_encrypted_searchable_columns, 'eq']
      end

      # Those same terms as words, lower case but for the acronyms among them.
      def recourse_search_names(except: nil)
        fields, = recourse_search_terms(except:)

        fields.map { |field| Recourse.downcase recourse_term_name(field) }
      end

      # A term is a column of this model, or a `zip_code` reaching through one of its
      # foreign keys — which a form and a table already have a name for.
      def recourse_term_name(field)
        reached = recourse_searchable_associations.find { |one| field.start_with? "#{one.name}_" }
        return reached.klass.recourse_reference_name if reached

        human_attribute_name field
      end
    end
  end
end
