class CreatePlaces < ActiveRecord::Migration[8.1]
  # Thirty, which is more than one page of twenty and fewer than MENU_LIMIT.
  COUNT = 30

  def change
    create_table :places do |t|
      # Typed on a form, because 101 ZIPs are too many to list.
      t.references :zip, null: false, foreign_key: true
      # Picked from a menu, because three teams are not.
      t.references :team, null: false, foreign_key: true
      # Optional, and the one a nested route answers: /people/1/places.
      t.references :person, foreign_key: true

      t.string :name, null: false
      t.string :slug, limit: 20, null: false
      t.string :type

      t.integer :capacity, null: false
      t.float :rating
      t.decimal :area, precision: 8, scale: 2
      t.monetary :hourly_rate
      t.percentage :commission_rate

      t.string :phone
      t.date :opens_on
      t.datetime :audited_at

      # An enum the portable way: a string column with a check constraint reading the
      # model's own constant, so the two cannot drift apart at creation time.
      t.string :status, null: false, default: Place::STATUSES.first.to_s
      # Non-null, so the model states `inclusion` rather than `presence` — which
      # would reject `false` along with nil.
      t.boolean :active, null: false, default: true
      # Nullable on purpose: the third state a form has to offer.
      t.boolean :verified

      t.text :about
      t.string :website
      # Indexed, so it would be searched and sorted by — and hidden by the model, so
      # no screen shows it. The two together are what prove `recourse_hidden` wins.
      t.string :webhook_url

      # Deterministic, so it stays unique and can be looked up.
      t.string :secret
      # Not deterministic: a different ciphertext every write, so neither.
      t.text :notes

      t.timestamps
    end

    add_index :places, :name
    add_index :places, :slug, unique: true
    add_index :places, :status
    add_index :places, :webhook_url, unique: true
    add_check_constraint :places, status_check, name: 'places_status'

    up_only { COUNT.times { |number| Place.create! attributes_for(number) } }
  end

private

  def status_check
    values = Place::STATUSES.map { |status| "'#{status}'" }.join ', '

    "status in (#{values})"
  end

  # The first row carries every column, the second only what cannot be null, and the
  # rest fill the table out — so one page shows both a full row and an empty one.
  def attributes_for(number)
    required = {
      zip_id: (number % 101) + 1, team_id: (number % 3) + 1,
      name: "Place #{format '%02d', number + 1}", slug: format('place-%02d', number + 1),
      capacity: (number + 1) * 5, status: Place::STATUSES[number % Place::STATUSES.size],
      active: number.even?,
    }
    return required if number == 1

    required.merge optional_attributes(number)
  end

  def optional_attributes(number)
    {
      person_id: (number % 10) + 1, rating: (number % 5) + 0.5,
      area: 100.25 + number, hourly_rate: 20 + number, commission_rate: 5.25,
      phone: format('415555%04d', number), opens_on: Date.new(2026, 1, 1) + number,
      audited_at: Time.zone.local(2026, 6, 1, 9, 30) + number.hours, verified: number.odd?,
      about: "A place that is number #{number + 1} of #{COUNT}.",
      website: "https://place-#{number + 1}.example.com",
      webhook_url: "https://hooks.example.com/#{number + 1}",
      secret: format('SEC-%04d', number), notes: "Private note #{number + 1}.",
    }
  end
end
