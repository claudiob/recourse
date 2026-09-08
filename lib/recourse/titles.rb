# Reopened for what a page calls things: the words a resource, a model and a column
# are read out under, which several helpers were each spelling for themselves.
module Recourse
  # What a resource and a model are called on a page. Extended onto `Recourse`, so
  # every one of these is `Recourse.something` wherever it is called from.
  module Titles
    # Lower case, but for the words Rails was told are acronyms: `ZIP code` reads as
    # `ZIP code` and never `zip code`, while `Code or Name` becomes `code or name`.
    # The plural of one counts as one, so `8 ZIPs` survives a host that registered
    # `ZIP` alone — pluralizing an acronym is the gem's job, not the host's.
    def downcase(text)
      acronyms = ActiveSupport::Inflector.inflections.acronyms

      text.split.map do |word|
        known = [word, word.singularize].any? { |one| acronyms.key? one.downcase }

        known ? word : word.downcase
      end.join ' '
    end

    # The plural title a resource is shown under, read off its model rather than out
    # of its path: `ZIP` pluralizes to `ZIPs`, where humanizing `zips` says `Zips`
    # unless the host registers that word as an acronym of its own. It also follows a
    # model renamed in a locale file, which humanizing a path never would.
    def title(name)
      model_title model(name)
    end

    # The same for a name that may resolve to no model at all: an action drawn under
    # a record still needs a word for its button, and `pause` is a verb this app never
    # made a class for.
    def known_title(name)
      segment = name.to_s.split('/').last
      model = segment.classify.safe_constantize

      model ? model_title(model) : segment.humanize
    end

    # And the singular of that, for the two places a page stands for one record rather
    # than a list: the tab a singular resource earns, and the button a bare action
    # earns. Off `known_title` rather than `model_title(count: 1)`, since a name this
    # app has no class for is humanized from a plural path segment and needs
    # singularizing too.
    def known_singular(name)
      known_title(name).singularize
    end

    # And the same for a model already in hand — the far side of an association, the
    # model a filter lists. `count:` picks the singular where one is meant, and
    # `lower:` is for a title that follows a word rather than opening the line.
    def model_title(model, count: nil, lower: false)
      title = model.model_name.human.pluralize count

      lower ? downcase(title) : title
    end
  end

  extend Titles
end
