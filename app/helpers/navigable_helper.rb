# A collection of helper to display root resources as a Bootstrap-styled navbar.
module NavigableHelper
  # @return [Array<String, String>] caption and URL of each link a top-level resource.
  def navigation_links
    Recourse.resources.select { |k, v| v[:routes].include? :index }.map do |resource, options|
      [resource.to_s.singularize.humanize.pluralize, url_for(resource)]
    end
  end
end
