class Bird < ApplicationRecord
  FACT_MAX_LENGTH = 280

  has_many :photos, dependent: :destroy

  normalizes :common_name, :scientific_name, with: ->(name) { name.squish }
  normalizes :fact, with: ->(fact) { fact.squish.presence }

  validates :common_name, presence: true, uniqueness: { case_sensitive: false }
  validates :scientific_name, presence: true, uniqueness: { case_sensitive: false }
  validates :fact, length: { maximum: FACT_MAX_LENGTH }
end
