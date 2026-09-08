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
      # `recourse` rather than `recourses`: one memo about this place, reached with
      # no id of its own. Routed `show` as well, so it is a page with a tab of its
      # own, and the delete stands on that page only while there is one to delete.
      recourse :memo, only: %i[show destroy]
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
      # No `Photo` in this app: the name is what the place has attached, and the
      # table is of Active Storage's blobs.
      recourses :photos, only: :index
    end

    # Everything but making one: a person arrives from somewhere else.
    recourses :people, except: %i[new create] do
      # A counted tab on the person's card, since places carry a counter cache.
      recourses :places, only: :index
      # And an uncounted one. `create` with no `new`: the navbar offers the
      # one-click Create button in the Add link's place, on our word that a bare
      # memo can stand.
      recourses :memos, only: %i[index create]
      # Every team, with the membership to add or drop beside each one — a listing
      # of the far side of a many-to-many rather than of the rows already joined,
      # which is what `through:` says and what the buttons in it write.
      recourses :teams, only: :index, through: :memberships
      # An action rather than a page: `create` with no index to reach it from, so
      # its button sits on the person instead, beside the breadcrumbs. Nothing here
      # answers it, so the gem does — and a write with no page of its own to land on
      # goes back to the record the button stood on.
      namespace(:quick) { recourses :memos, only: :create }
    end

    recourses :teams, except: :show do
      # A plain `resource`, so the gem records nothing and offers no button: the
      # wording counts what a sweep would clear, which is the host's to say.
      resource :sweep, only: :create
      # A `namespace` between a block and what it nests: the routes and the
      # controller come out under it, and no tab is drawn for a child filed there.
      namespace(:visited) { recourses :places, only: :index }
      # A nested index the parent has no `has_many` for, which a host draws over an
      # aggregate, an attachment, or the whole of a table read under one record. The
      # tab is named after the route, since there is no association to count or to
      # take an icon from.
      recourses :memos, only: :index
    end

    # Edited but never shown, and the table a foreign key is typed to reach.
    recourses :zips, only: %i[index edit update] do
      # No `only:` and no `except:`, so a nested resource takes the collection
      # actions by default: list the parent's rows, and add one.
      recourses :places
      # And the same over a key that names no one table. Nothing in the path says
      # `about`, so what settles it is the ZIP's own `has_many :notes, as: :about`.
      recourses :notes
    end
  end

  # What the sidebar's own way out posts to, `recourse_extra_links` naming this path.
  resource :session, only: :destroy

  # Outside the module, and with an index template of the host's own.
  recourses :memos, except: :show

  # No index action, so no sidebar link and nothing for the gem to draw.
  recourses :placeholders, only: []

  # Declared last, so the letter its sidebar link answers to is one nothing above it
  # has taken. Its own key is what this table is here for: a menu of every reading is
  # past what a menu is, and an id is not a word the box could look through instead.
  recourses :readings, only: %i[index new create]

  # A resource with no rows of its own, assembled out of the memos. Its controller says
  # what the rows are and its own template says how they read; everything around them —
  # the crumbs, the sidebar, the paging — is the gem's.
  recourses :weeks, only: :index
end
