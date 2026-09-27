# Reopened for what a host says about the pages a shared cache may keep for everybody.
module Recourse
  # How long each keeper may hold a page a host called cacheable: the reader's browser
  # (`max_age`), a CDN in front of the host (`shared_max_age`), and for how long past
  # that either may show an old page while a new one is fetched (`stale_while_revalidate`)
  # or when the host does not answer (`stale_if_error`). In seconds.
  PUBLIC_CACHE = {
    max_age: 300, shared_max_age: 86_400, stale_while_revalidate: 86_400, stale_if_error: 604_800,
  }.freeze

  class << self
    # A Proc answering, for one request, whether its page is the same for everybody: run
    # in the controller, so `request` and whatever the host knows of who is reading are
    # there to ask. Nil, as it is until a host says, keeps every page private to the
    # reader, as before. A page it approves is sent with `public` cache headers, and is
    # drawn with none of what a reader's own browser tells the server — their zone, their
    # page size, their density, a form's token — since that page will be shown to others.
    attr_accessor :public_pages

    # A Proc answering what a public page's ETag is made of, in the controller: whatever
    # changes when the page would, and nothing that changes when it would not. A browser or
    # a CDN then asks whether it still stands and is told `304`, which costs a
    # `SELECT` and no render. Nil sends no ETag of the gem's own.
    attr_accessor :public_version

    # The numbers PUBLIC_CACHE holds, or a host's own where it has said.
    attr_writer :public_cache

    # @return [Hash{Symbol => Integer}] the seconds each keeper keeps a public page for.
    def public_cache = PUBLIC_CACHE.merge(@public_cache || {})
  end

  @public_pages = nil
  @public_version = nil
  @public_cache = nil
end
