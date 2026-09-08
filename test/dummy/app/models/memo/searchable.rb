class Memo
  # What a memo can be narrowed by beside the box, over and above what its columns
  # answer for by themselves.
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      # What a memo is about, as the two kinds this app writes into a polymorphic
      # type. No enum admits them, no key points at one table, and nothing in the
      # schema says which words the column holds — so the menu is named here or it
      # is not offered at all. Each option reads as a model's own plural and submits
      # the class name stored beside the id.
      def filter_fields
        subjects = [Place, ZIP].map { |one| [one.model_name.human.pluralize, one.name] }

        super.merge 'about_type_in' => { label: 'Subject', values: subjects }
      end
    end
  end
end
