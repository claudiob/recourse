class ZIP
  # Labels a ZIP by its code, since a ZIP has no name to show, and lists them in
  # that order rather than the order they were made.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      # `attr_readonly` is what stops Rails writing it after the first save; this is
      # what stops a screen offering to. The gem knows nothing of the first, so the
      # model says both — and the seed still fills it, because a row cannot save
      # without one.
      def recourse_hidden = :fips

      def recourse_order = :code
    end
  end
end
