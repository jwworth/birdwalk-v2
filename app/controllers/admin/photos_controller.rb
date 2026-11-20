module Admin
  class PhotosController < BaseController
    before_action :set_bird
    before_action :set_photo, only: %i[edit update destroy]

    def new
      @photo = @bird.photos.build
    end

    def create
      @photo = @bird.photos.build(photo_params)

      if @photo.save
        redirect_to edit_admin_bird_path(@bird), notice: "Photo was added."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @photo.update(photo_params)
        redirect_to edit_admin_bird_path(@bird), notice: "Photo was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @photo.destroy!
      redirect_to edit_admin_bird_path(@bird), notice: "Photo was deleted.", status: :see_other
    end

    private

    def set_bird
      @bird = Bird.find(params.expect(:bird_id))
    end

    def set_photo
      @photo = @bird.photos.find(params.expect(:id))
    end

    # A blank file field would otherwise remove the existing image.
    def photo_params
      params.expect(photo: [ :image, :source_url, :creator, :license_name, :license_url, :attribution_notes ])
        .tap { |attributes| attributes.delete(:image) if attributes[:image].blank? }
    end
  end
end
