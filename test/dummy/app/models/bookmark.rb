# A row somebody kept, so a table can open with it. Polymorphic on purpose: one table
# serves every model that declares the other half, which is what proves the gem reads
# a type column where there is one.
class Bookmark < ApplicationRecord
  belongs_to :person
  belongs_to :topic, polymorphic: true
end
