class Challenge < ApplicationRecord
  ROUND_COUNT = 5

  belongs_to :location
  has_many :rounds, -> { order(:position) }, dependent: :destroy, inverse_of: :challenge

  accepts_nested_attributes_for :rounds, reject_if: :new_blank_round?

  validates :rotation_position, numericality: { only_integer: true, greater_than: 0 }, uniqueness: true
  validates :location_id, uniqueness: { message: "already has a challenge" }

  scope :playable, -> {
    where(id: Round.playable.group(:challenge_id).having("count(*) = ?", ROUND_COUNT).select(:challenge_id))
  }

  scope :with_game_data, -> {
    includes(:location, rounds: [
      :first_distractor, :second_distractor, :third_distractor,
      { correct_bird: { photos: { image_attachment: :blob } } }
    ])
  }

  def playable?
    rounds.size == ROUND_COUNT && rounds.all?(&:playable?)
  end

  def complete_round_count
    rounds.count(&:complete?)
  end

  def build_missing_rounds
    (1..ROUND_COUNT).each do |position|
      rounds.build(position: position) unless rounds.any? { |round| round.position == position }
    end
  end

  private

  def new_blank_round?(attributes)
    attributes["id"].blank? && attributes.values_at(*Round::BIRD_COLUMNS).all?(&:blank?)
  end
end
