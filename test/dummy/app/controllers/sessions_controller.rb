# The way out of the sidebar, which every admin has and this one therefore has too.
# There is no session to end — this app authenticates nobody — so going somewhere and
# saying so is the whole of it, and that is enough to make the link the sidebar draws a
# link that arrives: `recourse_extra_links` names this path, and until now nothing
# answered it.
class SessionsController < ApplicationController
  def destroy
    flash.notice = 'Signed out'
    redirect_to places_path, status: :see_other
  end
end
