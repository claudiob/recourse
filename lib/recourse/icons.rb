# Reopened for the one thing a drawn resource cannot answer alone: which picture it
# is shown with, which its model names and Unicon translates.
module Recourse
  # What a resource is drawn with, by the name of the class a route resolves to, and
  # nil where there is no such class -- a bare action is drawn under a word this app
  # has no class for, and an icon is not worth raising over. A word that does resolve
  # is not a drawn model either where what it found never heard of `recourse_icon`:
  # `Message` may be a host's own class for gathering rows rather than a table of them,
  # and asking it would raise rather than draw nothing.
  def self.known_icon(name)
    model = name.to_s.split('/').last.classify.safe_constantize

    known_model_icon model if model.respond_to? :recourse_icon
  end

  # And for a model in hand. Nil rather than Unicon's circle where it has never heard
  # the concept: a crumb or a tab then draws no picture at all, since the circle
  # pictures nothing.
  def self.known_model_icon(model)
    concept = model.recourse_icon

    Unicon[concept][:bootstrap] if Unicon.names.include? concept
  end
end
