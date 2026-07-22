class Task < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[ running ]
  end

  def self.filter_fields
    { running_false: { prompt: 'Status', choices: { 'Running': '0', 'Stopped': '1' } } }
  end
end
