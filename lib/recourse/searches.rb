# Reopened for what a search box submits and what it says, which a page narrows by the
# association its route has already answered.
module Recourse
  # The predicate a search box submits: every term the model looks through, joined by
  # `or`. Nil where a model has nothing worth looking through, which is what leaves its
  # index without the form -- filters and all. `except:` drops the association a nested
  # route already answered, so a page pinned to one provider offers no box to search
  # them all.
  # @param model [Class] the model the page is about.
  # @param except [ActiveRecord::Reflection::AbstractReflection, nil] what the route said.
  # @return [String, nil] the predicate, or nothing where there is none.
  def self.search_field(model, except: nil)
    fields, predicate = model.recourse_search_terms(except:)
    return if fields.empty?

    "#{fields.join '_or_'}_#{predicate}"
  end

  # What the search box says while it is empty, naming what it looks through.
  # @param model [Class] the model the page is about.
  # @param except [ActiveRecord::Reflection::AbstractReflection, nil] what the route said.
  # @return [String, nil] the words, or nothing where there is nothing to look through.
  def self.search_prompt(model, except: nil)
    fields, predicate = model.recourse_search_terms(except:)
    return if fields.empty?

    list = model.recourse_search_names(except:).join ' or '

    I18n.t "recourse.searched_#{predicate}", list: list
  end
end
