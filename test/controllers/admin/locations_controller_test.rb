require "test_helper"

class Admin::LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }
  end

  test "requires admin credentials" do
    get admin_locations_path

    assert_response :unauthorized
  end

  test "lists locations" do
    get admin_locations_path, headers: @auth

    assert_response :success
    assert_select "td", "Acadia National Park"
    assert_select "td", "Maine"
  end

  test "creates a location" do
    assert_difference "Location.count", 1 do
      post admin_locations_path, headers: @auth,
        params: { location: { name: "Glacier National Park", state: "Montana" } }
    end

    assert_redirected_to admin_locations_path
  end

  test "re-renders the form when a location is invalid" do
    assert_no_difference "Location.count" do
      post admin_locations_path, headers: @auth, params: { location: { name: "", state: "" } }
    end

    assert_response :unprocessable_content
    assert_select ".errors li", "Name can't be blank"
  end

  test "updates a location" do
    location = locations(:yellowstone)

    patch admin_location_path(location), headers: @auth, params: { location: { state: "Montana" } }

    assert_redirected_to admin_locations_path
    assert_equal "Montana", location.reload.state
  end

  test "deletes a location without a challenge" do
    assert_difference "Location.count", -1 do
      delete admin_location_path(locations(:yellowstone)), headers: @auth
    end

    assert_redirected_to admin_locations_path
  end

  test "does not delete a location with a challenge" do
    assert_no_difference "Location.count" do
      delete admin_location_path(locations(:acadia)), headers: @auth
    end

    assert_redirected_to admin_locations_path
    assert_equal "Acadia National Park has a challenge and can't be deleted.", flash[:alert]
  end
end
