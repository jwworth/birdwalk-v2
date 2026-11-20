module Admin
  class LocationsController < BaseController
    before_action :set_location, only: %i[edit update destroy]

    def index
      @locations = Location.includes(:challenge).order(:name)
    end

    def new
      @location = Location.new
    end

    def create
      @location = Location.new(location_params)

      if @location.save
        redirect_to admin_locations_path, notice: "#{@location.name} was added."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: "#{@location.name} was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @location.destroy
        redirect_to admin_locations_path, notice: "#{@location.name} was deleted.", status: :see_other
      else
        redirect_to admin_locations_path, alert: "#{@location.name} has a challenge and can't be deleted.", status: :see_other
      end
    end

    private

    def set_location
      @location = Location.find(params.expect(:id))
    end

    def location_params
      params.expect(location: [ :name, :state ])
    end
  end
end
