module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Challenge not found" }, status: :not_found
    end

    rescue_from ActionController::ParameterMissing do |error|
      render json: { error: error.message }, status: :bad_request
    end

    private

    def find_playable_challenge(id)
      Challenge.playable.with_game_data.find(id)
    end

    def location_json(location)
      location.as_json(only: %i[name state])
    end

    def photo_json(photo)
      photo.as_json(only: %i[source_url creator license_name license_url attribution_notes])
        .merge("url" => url_for(photo.image))
    end
  end
end
