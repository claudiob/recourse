# Reopened for where the house bundle these pages are drawn from is served from.
module Recourse
  # The release of `houseaccount` they are drawn from, named once — the layout links its
  # stylesheet and its script, and the sidebar's toggle swaps a palette out of the same
  # release. A published version is never written again, so the bytes behind these URLs
  # cannot move under us, and a change to the bundle reaches these pages when somebody
  # moves this line and not before.
  BUNDLE = '0.17.0'

  class << self
    # Where that release is served from, with no trailing slash. jsdelivr's copy of the
    # published package by default, which is what every deployed app reads and the one
    # place all five of them draw from.
    #
    # A host that sets it to `''` serves the bundle itself, out of the `houseaccount`
    # gem: its engine answers `/css`, `/js` and `/theme` from its own `public/`. That is
    # how the bundle is worked on — a stylesheet or a controller can be tried on a real
    # page before the version carrying it is published — and it is the whole of what
    # such a host writes.
    attr_accessor :assets
  end

  @assets = "https://cdn.jsdelivr.net/npm/houseaccount@#{BUNDLE}/public"

  # One file of the bundle.
  def self.asset(path) = "#{assets}/#{path}"

  # And the folder one palette is read from, which three places ask for: the layout
  # links the one a host named, the sidebar's toggle rotates through the rest, and the
  # layout's own script puts back whichever the reader chose last time.
  def self.themes_path = asset('theme')
end
