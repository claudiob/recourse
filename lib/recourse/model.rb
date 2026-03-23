require 'recourse/model/recoursive'
require 'recourse/model/searchable'


ActiveSupport.on_load(:active_record) do
  extend Recourse::Recoursive
  extend Recourse::Searchable
end
