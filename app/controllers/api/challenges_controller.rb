module Api
  class ChallengesController < BaseController
    def show
      challenge = find_playable_challenge(params.expect(:id))

      render json: {
        id: challenge.id,
        location: location_json(challenge.location),
        rounds: challenge.rounds.map { |round| round_json(round) }
      }
    end

    private

    def round_json(round)
      {
        id: round.id,
        position: round.position,
        photo: photo_json(round.photo),
        choices: round.birds.shuffle.map { |bird| bird.as_json(only: %i[id common_name]) }
      }
    end
  end
end
