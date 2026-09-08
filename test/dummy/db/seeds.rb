Contact.find_or_create_by! phone: '5552234567' do |contact|
  contact.name = 'Ada'
  contact.surname = 'Lovelace'
  contact.email = 'ada@example.com'
end

Contact.find_or_create_by! phone: '5552234568' do |contact|
  contact.name = 'Grace'
  contact.surname = 'Hopper'
end

Contact.find_or_create_by! phone: '5552234569'
