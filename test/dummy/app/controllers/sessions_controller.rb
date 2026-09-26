# The way out of the sidebar, which every admin has and this one therefore has too.
# There is no session to end — this app authenticates nobody — so going somewhere and
# saying so is the whole of it, and that is enough to make the button the sidebar draws
# for the route named `exit` a button that arrives.
#
# A `RecoursesController` like every other screen of an admin, that being where a host
# keeps the filters guarding it — and a singular resource, so the path it answers at
# carries no id and this app has no `Session` to look one up in either way.
class SessionsController < RecoursesController
  # The way in, which the sidebar links to for the route named `enter`. Nobody is
  # authenticated here either, so saying where the form would be is all of it.
  def new
    render plain: 'Sign in here'
  end

  def destroy
    flash.notice = 'Signed out'
    redirect_to places_path, status: :see_other
  end
end
