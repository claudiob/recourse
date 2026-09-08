# Reopened for the one thing a host says about how a viewer keeps a row.
module Recourse
  class << self
    # What a host wrote in the initializer, kept unresolved: a Proc is the only shape
    # that can name the viewer, since a relation built at boot would hold the agent
    # who was signed in then — which is nobody.
    attr_reader :declared_bookmarks
  end

  # How bookmarks are stored: a Proc answering the viewer's rows, or a relation or a
  # model where nobody in particular is looking. Nil turns the column off everywhere.
  def self.bookmarks=(bookmarks)
    @declared_bookmarks = bookmarks
  end

  # Whether a host declared any, asked while the routes draw — where resolving one
  # would run a host's Proc long before there is a request for it to read.
  def self.bookmarks? = !@declared_bookmarks.nil?

  # The viewer's bookmarks, resolved for this request.
  def self.bookmarks
    bookmarks = @declared_bookmarks
    bookmarks = bookmarks.call if bookmarks.respond_to? :call

    bookmarks&.all
  end

  # How a model's bookmarks point back at it: its own `has_many` at the bookmark
  # class, which is both the opt-in and everything needed to write one. A model that
  # cannot hold a bookmark has not declared one, so it gets no column.
  def self.bookmarks_for(model)
    return unless bookmarks?

    klass = bookmarks.klass
    model.reflect_on_all_associations(:has_many).find { |one| one.klass == klass }
  end

  # The viewer's bookmarks of one model: the type narrows them where the association
  # is polymorphic, and where it is not there is nothing to narrow by — `type` is set
  # from `as:` and nil without it, so a host whose bookmarks belong to one model needs
  # no type column and is asked for none. The ids behind the icons, the row a click
  # writes and the row a click drops all start here.
  def self.bookmarks_of(reflection)
    return bookmarks unless reflection.type

    # `polymorphic_name` rather than the class's own: it resolves through `base_class`,
    # which is what Rails writes into the column, so a subclass stays filed with the
    # table it shares.
    bookmarks.where reflection.type => reflection.polymorphic_name
  end
end
