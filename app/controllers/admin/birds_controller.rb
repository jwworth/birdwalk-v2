module Admin
  class BirdsController < BaseController
    before_action :set_bird, only: %i[edit update destroy]

    def index
      @birds = Bird.includes(:photos).order(:common_name)
    end

    def new
      @bird = Bird.new
    end

    def create
      @bird = Bird.new(bird_params)

      if @bird.save
        redirect_to admin_birds_path, notice: "#{@bird.common_name} was added."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @bird.update(bird_params)
        redirect_to admin_birds_path, notice: "#{@bird.common_name} was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @bird.destroy!
      redirect_to admin_birds_path, notice: "#{@bird.common_name} was deleted.", status: :see_other
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_birds_path, alert: "#{@bird.common_name} is used in a challenge and can't be deleted.", status: :see_other
    end

    private

    def set_bird
      @bird = Bird.find(params.expect(:id))
    end

    def bird_params
      params.expect(bird: [ :common_name, :scientific_name, :fact ])
    end
  end
end
