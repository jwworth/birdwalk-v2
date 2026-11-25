class DailyChallenge < ApplicationRecord
  TIME_ZONE = "America/New_York"

  belongs_to :challenge

  validates :date, presence: true

  def self.today
    featured_on(Time.find_zone!(TIME_ZONE).today)
  end

  # Today's choice is saved so that later admin changes only affect future days.
  # The unique index on date makes simultaneous first requests agree on one row.
  def self.featured_on(date)
    featured = find_by(date: date)
    return featured if featured && Challenge.playable.exists?(featured.challenge_id)

    challenge = next_challenge(date)
    return if challenge.nil?

    if featured
      featured.update!(challenge: challenge)
      featured
    else
      create_or_find_by!(date: date) { |daily| daily.challenge = challenge }
    end
  end

  def self.next_challenge(date)
    playable = Challenge.playable.order(:rotation_position).to_a
    return if playable.empty?

    previous = where(date: ...date).order(date: :desc).first
    return playable.first if previous.nil?

    start = playable.index { |challenge| challenge.rotation_position > previous.challenge.rotation_position } || 0
    elapsed_days = (date - previous.date).to_i
    playable[(start + elapsed_days - 1) % playable.size]
  end
  private_class_method :next_challenge
end
