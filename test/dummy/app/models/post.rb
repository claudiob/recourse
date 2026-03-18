class Post < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[ content ]
  end

  # Returns the name of the field to search specialtys with Ransack.
  def self.search_field
    :content_cont
  end

  # Returns the placeholder for the field to search specialtys with Ransack.
  def self.search_placeholder
    'Filter by content'
  end
end
