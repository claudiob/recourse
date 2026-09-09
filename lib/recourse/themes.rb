# Reopened for the other thing a host says about how every page looks.
module Recourse
  # Palettes a host may draw its pages in: eight color schemes from code editors, and
  # Bootstrap's own — which is what a page wears when none is named at all, so nil and
  # `:bootstrap` are two spellings of one look. It is named all the same, because the
  # sidebar's toggle rotates through this list and a reader who never finds upstream's
  # palette in it can never get back to it.
  #
  # Each is mapped to the families whose 500 step its palette puts dark text on rather
  # than white. That is the one thing about a palette the gem reads; everything else
  # about it — every ramp, and the accent it leads with — is in its stylesheet, which
  # is the only place it could be true.
  THEMES = {
    bootstrap: DARK_INKS,
    dawn: %i[brown cyan gray orange pink purple yellow],
    dracula: %i[blue brown cyan green orange pink purple red yellow],
    gruvbox: %i[cyan gray green yellow],
    monokai: %i[blue brown cyan green orange purple yellow],
    nord: %i[brown cyan green orange pink purple yellow],
    one_dark: %i[blue brown cyan gray green orange pink purple red yellow],
    solarized: %i[blue brown cyan gray green yellow],
    tokyo_night: %i[blue brown cyan gray green orange pink purple red yellow],
  }.freeze

  # Where the palettes are served from, named once: the layout links one, the layout's
  # own script puts back the one a reader chose, and the sidebar's controller swaps it.
  THEMES_PATH = '/recourse/themes'

  # Where a reader's chosen palette and mode are kept in their browser. Named once for
  # the same reason: the sidebar's controller writes it and the layout reads it back.
  SCHEME_STORAGE = 'recourse-scheme'

  class << self
    # Which editor scheme the pages are drawn in, or nil for Bootstrap's own palette.
    attr_reader :theme
  end

  # Picks the scheme, and says which eight there are when handed anything else. A name
  # nobody ships would otherwise ask the browser for a stylesheet that is not there and
  # go unnoticed until somebody looked at a page.
  def self.theme=(theme)
    name = theme&.to_sym
    unless name.nil? || THEMES.key?(name)
      raise Error, I18n.t('recourse.unknown_theme', theme:, themes: THEMES.keys.to_sentence)
    end

    @theme = name
  end
end
