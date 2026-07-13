# A collection of helper to display root resources as a Bootstrap-styled navbar.
module NavigableHelper
  # Boostrap icons to be used for specific resources.
  NAVIGATION_ICONS = {
    'Answers' => 'question-circle', 'Apps' => 'window', 'Assessments' => 'clipboard-check',
    'Bookings' => 'calendar-check', 'Brands' => 'buildings', 'Campaigns' => 'megaphone',
    'Conversations' => 'chat-dots', 'Counties' => 'map', 'Episodes' => 'collection-play',
    'Evaluations' => 'speedometer2', 'Franchises' => 'shop', 'Home' => 'home',
    'Logout' => 'box-arrow-right', 'Markets' => 'pin-map', 'Offer questions' => 'gift',
    'Optimizations' => 'sliders', 'Platforms' => 'plugin', 'Prompts' => 'terminal',
    'Providers' => 'people-fill', 'Satisfaction questions' => 'emoji-smile', 'Searches' => 'search',
    'Settings' => 'gear', 'Specialties' => 'award', 'Specialty matches' => 'award',
    'Verticals' => 'bar-chart', 'ZIPs' => 'geo-alt-fill',
  }

  # @return [Array<String, String>] caption and URL of each link a top-level resource.
  def navigation_links
    Recourse.resources.select { |k, v| v[:routes].include? :index }.map do |resource, options|
      caption = resource.to_s.singularize.humanize.pluralize
      [caption, url_for(resource), navigation_icon_for(caption)]
    end
  end

private

  # @return [String] a meaningful icon based on the resource name, or a generic one if not found.
  def navigation_icon_for(caption, style: nil)
    icon = NAVIGATION_ICONS.fetch caption, 'house-door-fill'
    tag.i class: "bi bi-#{icon}", style: style
  end
end
