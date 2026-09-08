Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort. Each
  # line draws a different slice of the seven, so the pages a resource offers — and
  # the links the gem draws to them — are covered between them.
  #
  # `scope module:` rather than `namespace`: the controllers live under `Admin::`
  # while the paths stay where a reader expects them — `/places`, not
  # `/admin/places`.
  scope module: :admin do
    # All seven, and the model that has a column of every kind.
    recourses :places do
      # A name this app has no class for at all: an action is a verb, and the button
      # still needs a word.
      recourses :sweeps, only: :create
      # And one with a model and no form: nothing to fill in, so the button that makes
      # the record stands on the place's page, and a second press is refused.
      recourses :seals, only: :create
    end

    # Everything but making one: a person arrives from somewhere else.
    recourses :people, except: %i[new create] do
      # A counted tab on the person's card, since places carry a counter cache.
      recourses :places, only: :index
      # And an uncounted one. `create` with no `new`: the navbar offers the
      # one-click Create button in the Add link's place, on our word that a bare
      # memo can stand.
      recourses :memos, only: %i[index create]
      # An action rather than a page: `create` with no index to reach it from, so
      # its button sits on the person instead, beside the breadcrumbs. Nothing here
      # answers it, so the gem does — and a write with no page of its own to land on
      # goes back to the record the button stood on.
      namespace(:quick) { recourses :memos, only: :create }
    end

    recourses :teams, except: :show do
      # A `namespace` between a block and what it nests: the routes and the
      # controller come out under it, and no tab is drawn for a child filed there.
      namespace(:visited) { recourses :places, only: :index }
      # A nested index the parent has no `has_many` for: the whole of a table read
      # under one record. The tab is named after the route, since there is no
      # association to count or to take an icon from.
      recourses :memos, only: :index
    end

    # Edited but never shown, and the table a foreign key is typed to reach.
    recourses :zips, only: %i[index edit update] do
      # No `only:` and no `except:`, so a nested resource takes the collection
      # actions by default: list the parent's rows, and add one.
      recourses :places
    end
  end

  # The way out of the sidebar. Named `exit`, which is what earns it the button beside
  # the toggle: the route is the whole declaration, and the controller is this app's.
  resource :session, only: :destroy, as: :exit

  # Outside the module, and with an index template of the host's own.
  recourses :memos, except: :show

  # No index action, so no sidebar link and nothing for the gem to draw.
  recourses :placeholders, only: []

  # Declared last, so the letter its sidebar link answers to is one nothing above it
  # has taken. Its own key is what this table is here for: a menu of every reading is
  # past what a menu is, and an id is not a word the box could look through instead.
  recourses :readings, only: %i[index new create]
end
