class Task < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[ running ]
  end

  # Returns the name of the field to filter bookings with Ransack.
  def self.filter_field
    :running_false
  end

  # Returns the prompt for the filter selector.
  def self.filter_prompt
    'Status'
  end

  # Returns the values to filter bookings by with Ransack.
  def self.filter_choices
    { 'Running': '0', 'Stopped': '1' }
  end
end
