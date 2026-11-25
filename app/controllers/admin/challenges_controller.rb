module Admin
  class ChallengesController < BaseController
    before_action :set_challenge, only: %i[edit update destroy]
    before_action :set_form_options, only: %i[new create edit update]

    def index
      @challenges = Challenge.includes(:location, rounds: { correct_bird: :photos }).order(:rotation_position)
    end

    def new
      @challenge = Challenge.new(rotation_position: Challenge.maximum(:rotation_position).to_i + 1)
      @challenge.build_missing_rounds
    end

    def create
      @challenge = Challenge.new(challenge_params)

      if @challenge.save
        redirect_to admin_challenges_path, notice: "#{@challenge.location.name} challenge was added."
      else
        @challenge.build_missing_rounds
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @challenge.build_missing_rounds
    end

    def update
      if @challenge.update(challenge_params)
        redirect_to admin_challenges_path, notice: "#{@challenge.location.name} challenge was updated."
      else
        @challenge.build_missing_rounds
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @challenge.destroy!
      redirect_to admin_challenges_path, notice: "#{@challenge.location.name} challenge was deleted.", status: :see_other
    end

    private

    def set_challenge
      @challenge = Challenge.find(params.expect(:id))
    end

    def set_form_options
      @locations = Location.order(:name)
      @birds = Bird.order(:common_name)
    end

    def challenge_params
      params.expect(challenge: [
        :location_id,
        :rotation_position,
        rounds_attributes: [ [ :id, :position, *Round::BIRD_COLUMNS ] ]
      ])
    end
  end
end
