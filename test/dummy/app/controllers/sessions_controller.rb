# The way out of the sidebar, which every admin has and this one therefore has too.
# There is no session to end — this app authenticates nobody — so going somewhere and
# saying so is the whole of it, and that is enough to make the button the sidebar draws
# for the route named `exit` a button that arrives.
#
# A `RecoursesController` like every other screen of an admin, that being where a host
# keeps the filters guarding it — and a singular resource, so the path it answers at
# carries no id and this app has no `Session` to look one up in either way.
class SessionsController < RecoursesController
  def destroy
    flash.notice = 'Signed out'
    redirect_to places_path, status: :see_other
  end
end
