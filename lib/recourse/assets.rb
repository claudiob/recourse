# Reopened for where the design layer these pages are drawn from is served from.
module Recourse
  class << self
    # Where bh's built files answer from, with no trailing slash. Its own engine by
    # default, which every app holding the gem already serves, so nothing is fetched
    # across a network and no version is written down twice: the gem in the lock file
    # is the one on the page.
    #
    # A host serving those files from somewhere else — a CDN, a bundle of its own that
    # carries bh's layer — points this at it, and that is the whole of what it writes.
    attr_accessor :assets
  end

  @assets = Bh::Engine::PREFIX.chomp '/'

  # One file of the design layer.
  def self.asset(path) = "#{assets}/#{path}"

  # And the folder one palette is read from, which three places ask for: the layout
  # links the one a host named, the sidebar's toggle rotates through the rest, and the
  # layout's own script puts back whichever the reader chose last time.
  def self.themes_path = asset('theme')
end
