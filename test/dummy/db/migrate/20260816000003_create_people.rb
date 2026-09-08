class CreatePeople < ActiveRecord::Migration[8.1]
  # Ten of them, each with one place and a couple of memos, so a card has a counted
  # tab and an uncounted one side by side.
  PEOPLE = %w[Ada Bram Cleo Dara Emil Fern Gus Hana Ivo Juno].freeze

  def change
    create_table :people do |t|
      t.string :name, null: false
      # Ciphertext, so the column says nothing about the shape of what it holds:
      # no limit, and the uniqueness the model earns with `deterministic: true`.
      t.string :email, null: false
      t.integer :places_count, null: false, default: 0

      t.timestamps
    end

    add_index :people, :name
    add_index :people, :email, unique: true

    # Written through the model rather than in SQL: the email is encrypted, so a
    # plain insert would store a readable address the app could never match.
    up_only do
      PEOPLE.each { |name| Person.create! name: name, email: "#{name.downcase}@example.com" }
    end
  end
end
