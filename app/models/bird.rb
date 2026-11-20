class Bird < ApplicationRecord
  has_many :photos, dependent: :destroy

  normalizes :common_name, :scientific_name, with: ->(name) { name.squish }

  validates :common_name, presence: true, uniqueness: { case_sensitive: false }
  validates :scientific_name, presence: true, uniqueness: { case_sensitive: false }
end
