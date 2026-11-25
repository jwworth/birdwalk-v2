module Api
  class ChallengesController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Challenge not found" }, status: :not_found
    end

    def show
      challenge = Challenge.playable
        .includes(:location, rounds: [
          :first_distractor, :second_distractor, :third_distractor,
          { correct_bird: { photos: { image_attachment: :blob } } }
        ])
        .find(params.expect(:id))

      render json: {
        id: challenge.id,
        location: challenge.location.as_json(only: %i[name state]),
        rounds: challenge.rounds.map { |round| round_json(round) }
      }
    end

    private

    def round_json(round)
      {
        id: round.id,
        position: round.position,
        photo: photo_json(round.correct_bird.photos.min_by(&:created_at)),
        choices: round.birds.shuffle.map { |bird| bird.as_json(only: %i[id common_name]) }
      }
    end

    def photo_json(photo)
      photo.as_json(only: %i[source_url creator license_name license_url attribution_notes])
        .merge("url" => url_for(photo.image))
    end
  end
end
