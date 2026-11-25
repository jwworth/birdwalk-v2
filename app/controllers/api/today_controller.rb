module Api
  class TodayController < BaseController
    def show
      daily = DailyChallenge.today
      if daily.nil?
        render json: { error: "No challenge is available today" }, status: :not_found
        return
      end

      challenge = find_playable_challenge(daily.challenge_id)
      render json: challenge_json(challenge).merge(date: daily.date.iso8601)
    end
  end
end
