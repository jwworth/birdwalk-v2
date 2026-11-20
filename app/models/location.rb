class Location < ApplicationRecord
  has_one :challenge, dependent: :restrict_with_error

  normalizes :name, :state, with: ->(value) { value.squish }

  validates :name, presence: true, uniqueness: { scope: :state, case_sensitive: false }
  validates :state, presence: true

  def display_name
    "#{name}, #{state}"
  end
end
