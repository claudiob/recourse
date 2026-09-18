# Somebody a place answers to. The card page: one tab counting their places and
# one naming their memos, and an address only their own page reads out.
class Person < ApplicationRecord
  include Emailable

  # A place answers to somebody, so it goes when they do.
  has_many :places, dependent: :destroy
  # A memo outlives whoever it was about, and keeps no counter cache — so the tab
  # beside Places reads as the bare word.
  has_many :memos, dependent: :nullify
  # A shift is somebody's, so it goes when they do.
  has_many :shifts, dependent: :destroy
  # And a step is theirs to work through, in an order of their own: the second listing
  # of an arranged model, read under a key its position is not counted within.
  has_many :steps, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
