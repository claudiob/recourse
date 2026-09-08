module Recourse
  # Whose clock a page is drawn against. The browser says which zone it is in and the
  # server renders in it, so a time, a date and the field that edits one all agree —
  # which is what rendering in the browser instead could never have given.
  module Zoning
    extend ActiveSupport::Concern

    included do
      around_action :use_recourse_zone
    end

  private

    # For the length of one of the gem's own requests and no longer: `use_zone` swaps
    # `Time.zone`, yields, and puts the old one back in an `ensure`, and `Time.zone` is
    # per-thread state rather than config. So the host's setting is never written, and
    # a host's own screens are drawn against it as before, in the same second.
    def use_recourse_zone(&) = Time.use_zone(recourse_zone, &)

    # Nil where the browser has not said, or said something no zone answers to — and
    # `Time.zone = nil` falls back to the host's own setting, so an absent cookie and a
    # forged one both leave the page exactly as it is drawn today.
    def recourse_zone
      name = cookies[Recourse::ZONE_STORAGE]

      ActiveSupport::TimeZone[name] if name.present?
    end
  end
end
