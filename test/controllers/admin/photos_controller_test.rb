require "test_helper"

class Admin::PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }
    @bird = birds(:blue_jay)
  end

  def photo_params(**overrides)
    {
      image: fixture_file_upload("photo.png", "image/png"),
      source_url: "https://commons.wikimedia.org/wiki/File:Blue_jay.jpg",
      creator: "Jane Birder",
      license_name: "CC BY-SA 4.0",
      license_url: "https://creativecommons.org/licenses/by-sa/4.0/",
      attribution_notes: "Cropped from the original."
    }.merge(overrides)
  end

  def create_photo
    @bird.photos.create!(photo_params.merge(image: fixture_file_upload("photo.png", "image/png")))
  end

  test "requires admin credentials" do
    get new_admin_bird_photo_path(@bird)

    assert_response :unauthorized
  end

  test "uploads a photo with licensing information" do
    assert_difference [ "Photo.count", "ActiveStorage::Attachment.count" ], 1 do
      post admin_bird_photos_path(@bird), headers: @auth, params: { photo: photo_params }
    end

    assert_redirected_to edit_admin_bird_path(@bird)
    photo = @bird.photos.last
    assert photo.image.attached?
    assert_equal "Jane Birder", photo.creator
  end

  test "does not save a photo without licensing information" do
    assert_no_difference [ "Photo.count", "ActiveStorage::Attachment.count", "ActiveStorage::Blob.count" ] do
      post admin_bird_photos_path(@bird), headers: @auth,
        params: { photo: photo_params(creator: "", license_url: "") }
    end

    assert_response :unprocessable_content
    assert_select ".errors li", "Creator can't be blank"
    assert_select ".errors li", "License url can't be blank"
  end

  test "does not save a photo without an image" do
    assert_no_difference "Photo.count" do
      post admin_bird_photos_path(@bird), headers: @auth, params: { photo: photo_params(image: "") }
    end

    assert_response :unprocessable_content
    assert_select ".errors li", "Image must be attached"
  end

  test "updates licensing details while keeping the image" do
    photo = create_photo
    blob = photo.image.blob

    patch admin_bird_photo_path(@bird, photo), headers: @auth,
      params: { photo: { image: "", creator: "J. Birder", license_name: "CC BY 4.0" } }

    assert_redirected_to edit_admin_bird_path(@bird)
    photo.reload
    assert_equal "J. Birder", photo.creator
    assert_equal "CC BY 4.0", photo.license_name
    assert_equal blob, photo.image.blob
  end

  test "deletes a photo" do
    photo = create_photo

    assert_difference [ "Photo.count", "ActiveStorage::Attachment.count" ], -1 do
      delete admin_bird_photo_path(@bird, photo), headers: @auth
    end

    assert_redirected_to edit_admin_bird_path(@bird)
  end

  test "bird page shows each photo with its attribution" do
    create_photo

    get edit_admin_bird_path(@bird), headers: @auth

    assert_response :success
    assert_select ".photo img[alt='Blue Jay']"
    assert_select ".attribution", /Photo by Jane Birder/
    assert_select ".attribution a[href='https://creativecommons.org/licenses/by-sa/4.0/']", "CC BY-SA 4.0"
    assert_select ".attribution a[href='https://commons.wikimedia.org/wiki/File:Blue_jay.jpg']", "Source"
    assert_select ".attribution", /Cropped from the original\./
  end

  test "bird list shows photo counts" do
    create_photo

    get admin_birds_path, headers: @auth

    assert_select "tr", text: /Blue Jay/ do
      assert_select "td.photo-count", "2"
    end
  end
end
