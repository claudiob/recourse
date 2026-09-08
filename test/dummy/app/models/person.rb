# Somebody a place answers to. The card page: one tab counting their places and
# one naming their memos, and an address only their own page reads out.
class Person < ApplicationRecord
  include Emailable

  # A place answers to somebody, so it goes when they do.
  has_many :places, dependent: :destroy
  # A memo outlives whoever it was about, and keeps no counter cache — so the tab
  # beside Places reads as the bare word.
  has_many :memos, dependent: :nullify
  # The join a page edits: every team is listed, and each row says whether this
  # person is on it.
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
