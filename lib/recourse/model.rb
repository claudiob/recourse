require 'recourse/model/recoursive'
require 'recourse/model/searchable'

# TODO: Replace these with on_load
ActiveRecord::Base.extend Recourse::Recoursive
ActiveRecord::Base.extend Recourse::Searchable
