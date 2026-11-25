module Api
  class ScoresController < BaseController
    def create
      challenge = find_playable_challenge(params.expect(:challenge_id))
      score = ChallengeScore.new(challenge: challenge, answers: params.expect(answers: [ [ :round_id, :bird_id ] ]))

      if score.valid?
        render json: {
          id: challenge.id,
          location: location_json(challenge.location),
          correct_count: score.correct_count,
          round_count: score.rounds.size,
          rounds: score.rounds.map { |round| result_json(score, round) }
        }
      else
        render json: { errors: score.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    def result_json(score, round)
      {
        id: round.id,
        position: round.position,
        correct: score.correct?(round),
        selected_bird: score.selected_bird(round).as_json(only: %i[id common_name]),
        correct_bird: round.correct_bird.as_json(only: %i[id common_name scientific_name fact]),
        photo: photo_json(round.photo)
      }
    end
  end
end
