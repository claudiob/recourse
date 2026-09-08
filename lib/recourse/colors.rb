# Reopened for the one thing a host says about how every page looks.
module Recourse
  # Color families a host may call primary. Six of the sixteen Bootstrap ships; the
  # other ten are declined rather than forgotten.
  COLORS = %i[blue gray orange purple pink brown].freeze

  # Families whose 500 step carries dark text rather than white, because white on it
  # reads worse. The dark one is `--bs-gray-975`, the darkest neutral a palette has:
  # upstream already gives warning and info a dark label for the same reason, and white
  # on `orange-500` is 2.90:1, under the 3:1 a button's label owes.
  DARK_INKS = %i[amber blue brown cyan gray green lime orange pewter teal yellow].freeze

  class << self
    # Which family the pages call primary, or nil for Bootstrap's own blue.
    attr_reader :color
  end

  # Picks the primary color, and says which six there are when handed anything else. A
  # typo would otherwise write `var(--bs-purpel-500)` into every page and go unnoticed
  # until somebody looked at a button.
  def self.color=(color)
    name = color&.to_sym
    unless name.nil? || COLORS.include?(name)
      raise Error, I18n.t('recourse.unknown_color', color:, colors: COLORS.to_sentence)
    end

    @color = name
  end

  # Which text a family's 500 step carries, named as the token upstream spells it with.
  # A palette repaints the step, so it may move a family across the line and answers
  # first where it does.
  def self.ink(family)
    inks = THEMES[theme] || DARK_INKS

    inks.include?(family) ? 'gray-975' : 'white'
  end
end
