module Recourse
  # A page the host says is the same for everybody is sent for everybody to keep: a CDN
  # in front of the host serves it for a day, and asks the host only when it must.
  module PublicCaching
    extend ActiveSupport::Concern

    included do
      before_action :cache_for_everybody
      helper_method :public_page?
    end

  private

    # Whether this page is drawn once for everybody. Only a read: a page that changes
    # something is nobody else's, and a frame's request is answered with the frame alone,
    # which the same address answers with a whole page. Asked once per request, since the
    # host's answer may be a query and the layout, the zone and the paging all ask.
    def public_page?
      return @public_page if defined? @public_page

      @public_page = Recourse.public_pages.present? && (request.get? || request.head?) &&
                     !turbo_frame_request? && instance_exec(&Recourse.public_pages)
    end

    def cache_for_everybody
      return unless public_page?

      response.cache_control.merge! public_cache_control
      response.headers['Vary'] = [response.headers['Vary'], 'Turbo-Frame'].compact_blank.join ', '
      version = Recourse.public_version
      fresh_when etag: instance_exec(&version) if version
    end

    # `s-maxage` is the CDN's alone: the reader's browser keeps the page for `max-age`.
    def public_cache_control
      keep = Recourse.public_cache

      {
        public: true, max_age: keep[:max_age], extras: ["s-maxage=#{keep[:shared_max_age]}"],
        stale_while_revalidate: keep[:stale_while_revalidate],
        stale_if_error: keep[:stale_if_error],
      }
    end
  end
end
