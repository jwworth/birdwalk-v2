class Round < ApplicationRecord
  BIRD_COLUMNS = %w[correct_bird_id first_distractor_id second_distractor_id third_distractor_id].freeze

  belongs_to :challenge
  belongs_to :correct_bird, class_name: "Bird", optional: true
  belongs_to :first_distractor, class_name: "Bird", optional: true
  belongs_to :second_distractor, class_name: "Bird", optional: true
  belongs_to :third_distractor, class_name: "Bird", optional: true

  validates :position, numericality: { only_integer: true, in: 1..Challenge::ROUND_COUNT },
    uniqueness: { scope: :challenge_id }
  validate :birds_are_distinct

  scope :complete, -> {
    where.not(correct_bird_id: nil)
      .where.not(first_distractor_id: nil)
      .where.not(second_distractor_id: nil)
      .where.not(third_distractor_id: nil)
  }

  scope :playable, -> { complete.where(correct_bird_id: Photo.select(:bird_id)) }

  def complete?
    bird_ids.all?(&:present?)
  end

  def playable?
    complete? && correct_bird.photos.any?
  end

  def birds
    [ correct_bird, first_distractor, second_distractor, third_distractor ]
  end

  def photo
    correct_bird.photos.min_by { |photo| [ photo.created_at, photo.id ] }
  end

  private

  def bird_ids
    BIRD_COLUMNS.map { |column| self[column] }
  end

  def birds_are_distinct
    chosen = bird_ids.compact
    errors.add(:base, "Each bird in a round must be different") if chosen.uniq.size != chosen.size
  end
end
