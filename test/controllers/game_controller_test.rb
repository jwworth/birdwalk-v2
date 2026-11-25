require "test_helper"

class GameControllerTest < ActionDispatch::IntegrationTest
  test "root renders the React mount point and game script" do
    get root_path

    assert_response :success
    assert_select "div#root"
    assert_select "script[type=module][src*='application']"
  end
end
