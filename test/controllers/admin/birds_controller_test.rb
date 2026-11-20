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

  test "creates a bird with a fact" do
    post admin_birds_path, headers: @auth, params: {
      bird: { common_name: "Eastern Bluebird", scientific_name: "Sialia sialis", fact: "Bluebirds nest in tree cavities." }
    }

    assert_redirected_to admin_birds_path
    assert_equal "Bluebirds nest in tree cavities.", Bird.find_by!(common_name: "Eastern Bluebird").fact
  end

  test "updates a bird's fact" do
    patch admin_bird_path(@bird), headers: @auth, params: { bird: { fact: "Blue Jays cache acorns." } }

    assert_redirected_to admin_birds_path
    assert_equal "Blue Jays cache acorns.", @bird.reload.fact
  end

  test "rejects a fact that is too long" do
    patch admin_bird_path(@bird), headers: @auth, params: { bird: { fact: "a" * 281 } }

    assert_response :unprocessable_content
    assert_select ".errors li", "Fact is too long (maximum is 280 characters)"
    assert_select ".bird-fact p", "Blue Jays often mimic the calls of Red-shouldered Hawks."
  end

  test "bird page shows the fact" do
    get edit_admin_bird_path(@bird), headers: @auth

    assert_response :success
    assert_select ".bird-fact p", "Blue Jays often mimic the calls of Red-shouldered Hawks."
    assert_select "textarea[name='bird[fact]']", "Blue Jays often mimic the calls of Red-shouldered Hawks."
  end

  test "bird page notes a missing fact" do
    get edit_admin_bird_path(birds(:canada_jay)), headers: @auth

    assert_select ".bird-fact p.muted", "No fact yet."
  end

  test "bird list shows which birds have facts" do
    get admin_birds_path, headers: @auth

    assert_select "tr", text: /Blue Jay/ do
      assert_select "td.fact-status", "Yes"
    end
    assert_select "tr", text: /Canada Jay/ do
      assert_select "td.fact-status", "Missing"
    end
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
