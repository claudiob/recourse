# A host app's one line about what the pages are drawn from. A palette rather than
# Bootstrap's own, so what a scheme reaches — the page, its rules, its text and every
# accent on it — is visible in a browser rather than only in a test.
Recourse.theme = :dracula

# And deliberately no color, so each palette leads with the accent of its own that it
# names, which is what a reader rotating through them from the sidebar sees. A host that
# wants one says `Recourse.color = :blue`; the test about the color is what exercises
# that, since nothing here would.

# And where the bundle every page is drawn from is served from, which is the CDN unless
# somebody asks otherwise. `HOUSE_ASSETS=1 bin/rails s` in this app serves it out of the
# `houseaccount` gem beside this one instead, so a stylesheet or a Stimulus controller can
# be read on a real page before the release carrying it is published. Behind a variable
# rather than set outright, because what a deployed app links is what the suite asserts.
Recourse.assets = '' if ENV['HOUSE_ASSETS']

# And its one line about how a viewer keeps a row. A Proc rather than the relation
# itself: a relation built here would hold whoever was looking when the process
# booted, which in a real app is nobody. There is no session to read in a dummy, so
# the first person stands in for whoever is signed in.
Recourse.bookmarks = -> { Bookmark.where person: Person.order(:id).first }
