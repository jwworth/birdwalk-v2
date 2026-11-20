require "test_helper"

class Admin::BirdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }
    @bird = birds(:blue_jay)
  end

  test "requires admin credentials" do
    get admin_birds_path

    assert_response :unauthorized
  end

  test "rejects the wrong password" do
    wrong = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "wrong")

    get admin_birds_path, headers: { "HTTP_AUTHORIZATION" => wrong }

    assert_response :unauthorized
  end

  test "does not protect the public game" do
    get root_path

    assert_response :success
  end

  test "lists birds" do
    get admin_birds_path, headers: @auth

    assert_response :success
    assert_select "td", "Blue Jay"
    assert_select "td em", "Cyanocitta cristata"
  end

  test "creates a bird" do
    assert_difference "Bird.count", 1 do
      post admin_birds_path, headers: @auth,
        params: { bird: { common_name: "Eastern Bluebird", scientific_name: "Sialia sialis" } }
    end

    assert_redirected_to admin_birds_path
    assert_equal "Sialia sialis", Bird.find_by!(common_name: "Eastern Bluebird").scientific_name
  end

  test "re-renders the form when a bird is invalid" do
    assert_no_difference "Bird.count" do
      post admin_birds_path, headers: @auth,
        params: { bird: { common_name: "Blue Jay", scientific_name: "" } }
    end

    assert_response :unprocessable_content
    assert_select ".errors li", "Common name has already been taken"
    assert_select ".errors li", "Scientific name can't be blank"
  end

  test "updates a bird" do
    patch admin_bird_path(@bird), headers: @auth,
      params: { bird: { common_name: "Northern Blue Jay" } }

    assert_redirected_to admin_birds_path
    assert_equal "Northern Blue Jay", @bird.reload.common_name
  end

  test "deletes a bird" do
    assert_difference "Bird.count", -1 do
      delete admin_bird_path(birds(:cedar_waxwing)), headers: @auth
    end

    assert_redirected_to admin_birds_path
  end

  test "does not delete a bird used in a challenge" do
    assert_no_difference "Bird.count" do
      delete admin_bird_path(@bird), headers: @auth
    end

    assert_redirected_to admin_birds_path
    assert_equal "Blue Jay is used in a challenge and can't be deleted.", flash[:alert]
  end
end
