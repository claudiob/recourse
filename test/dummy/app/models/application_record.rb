# Base class every model in the dummy app inherits from.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
