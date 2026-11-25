require "test_helper"

class GameControllerTest < ActionDispatch::IntegrationTest
  test "root renders the React mount point and game script" do
    get root_path

    assert_response :success
    assert_select "div#root"
    assert_select "script[type=module][src*='application']"
  end

  test "root provides the first playable challenge in the rotation" do
    challenges(:acadia).update!(rotation_position: 2)
    earlier = Challenge.create!(location: locations(:yellowstone), rotation_position: 1)
    challenges(:acadia).rounds.each do |round|
      earlier.rounds.create!(round.attributes.slice("position", *Round::BIRD_COLUMNS))
    end

    get root_path

    assert_select "div#root[data-challenge-id=?]", earlier.id.to_s
  end

  test "root provides the challenge date in New York time" do
    travel_to Time.utc(2026, 11, 26, 3, 30) do
      get root_path
    end

    assert_select "div#root[data-challenge-date=?]", "2026-11-25"
  end

  test "root skips challenges that are not playable" do
    rounds(:acadia_round_3).update!(third_distractor: nil)

    get root_path

    assert_select "div#root"
    assert_select "div#root[data-challenge-id]", count: 0
  end
end
