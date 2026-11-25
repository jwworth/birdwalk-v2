class ChallengeScore
  include ActiveModel::Model

  attr_reader :challenge, :answers

  validate :answers_are_filled_in
  validate :each_round_is_answered_once
  validate :selected_birds_are_choices

  def initialize(challenge:, answers:)
    @challenge = challenge
    @answers = answers
  end

  def rounds
    challenge.rounds
  end

  def correct?(round)
    selected_bird(round) == round.correct_bird
  end

  def correct_count
    rounds.count { |round| correct?(round) }
  end

  def selected_bird(round)
    choice(round, answer_for(round)[:bird_id])
  end

  private

  def choice(round, bird_id)
    round.birds.detect { |bird| bird.id.to_s == bird_id.to_s }
  end

  def answer_for(round)
    answers.detect { |answer| answer[:round_id].to_s == round.id.to_s }
  end

  def round_for(answer)
    rounds.detect { |round| round.id.to_s == answer[:round_id].to_s }
  end

  def answers_are_filled_in
    if answers.any? { |answer| answer[:round_id].blank? || answer[:bird_id].blank? }
      errors.add(:base, "Each answer must include a round_id and a bird_id")
    end
  end

  def each_round_is_answered_once
    unless answers.size == Challenge::ROUND_COUNT
      errors.add(:base, "Exactly #{Challenge::ROUND_COUNT} answers are required")
    end

    answered_ids = answers.filter_map { |answer| answer[:round_id].presence&.to_s }
    round_ids = rounds.map { |round| round.id.to_s }

    answered_ids.tally.each do |round_id, count|
      errors.add(:base, "Round #{round_id} was answered more than once") if count > 1
    end
    (answered_ids.uniq - round_ids).each do |round_id|
      errors.add(:base, "Round #{round_id} is not part of this challenge")
    end
    (round_ids - answered_ids).each do |round_id|
      errors.add(:base, "Round #{round_id} was not answered")
    end
  end

  def selected_birds_are_choices
    answers.each do |answer|
      round = round_for(answer)
      next if round.nil? || answer[:bird_id].blank? || choice(round, answer[:bird_id])

      errors.add(:base, "Bird #{answer[:bird_id]} is not a choice for round #{round.id}")
    end
  end
end
