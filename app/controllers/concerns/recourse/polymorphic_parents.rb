module Recourse
  # Reads the parent behind a key that names no one table. Nothing about such a key
  # says which model a route meant, and the segment above it is the concrete parent's
  # own — `/verticals/5/notions`, never `/topics/5/notions` — so matching an
  # association's name against the path could never answer. The parent's own half of
  # the association is what answers instead.
  module PolymorphicParents
  private

    # The polymorphic belongs_to a nested route names, or nil where none does.
    # `has_many :notions, as: :topic` says both that this nesting is that association
    # and which key it is, for a model that keeps more than one.
    def polymorphic_parent
      name = parent_has_many&.options&.[] :as
      return unless name

      resource_class.reflect_on_association name
    end

    # The parent's `has_many` of the listed resource's own name, asked of the model
    # the routes recorded that listing under — read back rather than cut off the path,
    # since how many segments a nesting took is something the routes knew and a path
    # no longer says.
    #
    # Only where the path carries that model's id, and only where the parent declares
    # the other half: a nesting drawn over anything else — the memos of everyone on a
    # team, gathered from several parents at once — answers nothing here and stays the
    # host's to scope, exactly as it was before.
    def parent_has_many
      parent = Recourse.parent_of listing_path
      return unless parent && resource_model? &&
                    resource_class.respond_to?(:reflect_on_association)

      model = Recourse.model parent
      return unless path_names? model.model_name.singular

      model.reflect_on_association listing_path.split('/').last
    end

    # The path the rows being served are listed at, which is this controller's own
    # everywhere but under one of the gem's own writes: a position and a bookmark are
    # drawn beside a listing and act on its rows, so each answers with the path one
    # segment up instead — and the parent that scopes the listing scopes them too.
    def listing_path = controller_path
  end
end
