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
    recourses :places, retrievable: true do
      # A name this app has no class for at all: an action is a verb, and the button
      # still needs a word.
      recourse :sweep, only: :create
      # And one routed `show`: a page rather than an action, which Rails draws no
      # index for -- so the tab on the place is the only thing that reaches it.
      recourse :zip, only: :show
      # The same, and this one the gem serves whole: a `has_one` it reads off the
      # place, with `new` routed so an absent one is a form to fill in rather than a
      # page saying there is none.
      recourse :audit, only: %i[new create show]
      # And one routed `show create destroy`, which is a page and two verbs and no
      # form: nothing to fill in, so the button that makes the record and the one that
      # removes it both stand on the page that reads it, one at a time.
      recourse :seal, only: %i[show create destroy]
      # The same, over a record a place may not have: what the host finds is what the
      # page reads, and a page that finds nothing says so.
      recourse :person, only: :show
      # No `Photo` in this app: the name is what the place has attached, and the table
      # is of Active Storage's blobs. `destroy` with no `edit`, so each row carries it.
      recourses :photos, only: %i[index destroy]
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
      # The second listing of a positionable model, dragged into order by a column the
      # model does not keep. Both halves of it are this app's: the page and the write.
      recourses :steps, only: :index, positionable: true
      # A nested index this person has no association for, of a model whose name is an
      # acronym: the tab reads `ZIPs`, as the sidebar does, rather than the `Zips` the
      # path humanizes to.
      recourses :zips, only: :index
    end

    recourses :teams, except: :show, positionable: true do
      # A `namespace` between a block and what it nests: the routes and the
      # controller come out under it, and no tab is drawn for a child filed there.
      namespace(:visited) { recourses :places, only: :index }
      # The table put in order by hand, nested under the parent a place in it is counted
      # within. The keyword is what draws the route a drop is reported to; the column is
      # still what decides whether the grip is drawn and whether the write is allowed.
      recourses :steps, positionable: true
      # A nested index the parent has no `has_many` for: the whole of a table read
      # under one record. The tab is named after the route, since there is no
      # association to count or to take an icon from.
      recourses :memos, only: :index
      # And one the parent reaches only through another table, which is where the
      # figure on its tab comes from.
      recourses :zips, only: :index
    end

    # Edited but never shown, and the table a foreign key is typed to reach.
    recourses :zips, only: %i[index edit update] do
      # No `only:` and no `except:`, so a nested resource takes the collection
      # actions by default: list the parent's rows, and add one.
      recourses :places
    end
  end

  # The ways out of the sidebar and into it. Named `exit` and `enter`, which is what earns
  # each its place beside the toggle: the route is the whole declaration.
  resource :session, only: :destroy, as: :exit
  get 'session/new', to: 'sessions#new', as: :enter

  # Outside the module, and with an index template of the host's own.
  recourses :memos, except: :show

  # No index action, so no sidebar link and nothing for the gem to draw.
  recourses :placeholders, only: []

  # Two columns saying when a row opens and closes, which is what earns this table the
  # calendar beside it: `/shifts.cal` draws a week of them, and nothing is declared.
  recourses :shifts, only: %i[index show]

  # Declared last, so the letter its sidebar link answers to is one nothing above it
  # has taken. Its own key is what this table is here for: a menu of every reading is
  # past what a menu is, and an id is not a word the box could look through instead.
  recourses :readings, only: %i[index new create]
end
