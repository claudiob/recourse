ActiveSupport::Inflector.inflections :en do |inflect|
  # Every acronym this app names, and no others: an app registers what it says. The
  # gem it mounts registers nothing, the way it sets no time zone and no logger.
  inflect.acronym 'FIPS'
  inflect.acronym 'URL'
  # Singulars only: the gem pluralizes a model's own human name, so `ZIPs` reads
  # right on a page without `zips` camelizing to `ZIPs` for Rails — which would
  # rename the controller Rails computes from the path.
  inflect.acronym 'ZIP'
end
