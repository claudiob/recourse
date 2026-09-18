# A host's own class for gathering rows rather than a table of them, which a nested
# route may be named after: what the gem must not ask a model's hooks of.
class Rollup
  # Every row a person has a hand in, whichever table it is kept in.
  def self.from(person) = person.places + person.memos
end
