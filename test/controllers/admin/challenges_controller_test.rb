require "test_helper"

class Admin::ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }
    @challenge = challenges(:acadia)
  end

  test "requires admin credentials" do
    get admin_challenges_path

    assert_response :unauthorized
  end

  test "lists challenges with their status" do
    Challenge.create!(location: locations(:yellowstone), rotation_position: 2)

    get admin_challenges_path, headers: @auth

    assert_response :success
    assert_select "td", "Acadia National Park, Maine"
    assert_select ".status.playable", "Playable"
    assert_select ".status.incomplete", /0 of 5 rounds/
  end

  test "new form shows five rounds with bird choices" do
    get new_admin_challenge_path, headers: @auth

    assert_response :success
    assert_select "fieldset.round", 5
    assert_select "select[name='challenge[rounds_attributes][0][correct_bird_id]'] option", text: "Blue Jay"
    assert_select "input[name='challenge[rotation_position]'][value='2']"
  end

  test "creates an incomplete challenge, skipping blank rounds" do
    assert_difference [ "Challenge.count", "Round.count" ], 1 do
      post admin_challenges_path, headers: @auth, params: {
        challenge: {
          location_id: locations(:yellowstone).id,
          rotation_position: 2,
          rounds_attributes: {
            "0" => { position: 1, correct_bird_id: birds(:blue_jay).id, first_distractor_id: birds(:canada_jay).id },
            "1" => { position: 2, correct_bird_id: "", first_distractor_id: "", second_distractor_id: "", third_distractor_id: "" }
          }
        }
      }
    end

    assert_redirected_to admin_challenges_path
    challenge = Challenge.find_by!(rotation_position: 2)
    assert_equal birds(:canada_jay), challenge.rounds.first.first_distractor
    assert_not challenge.playable?
  end

  test "re-renders the form when a round repeats a bird" do
    assert_no_difference [ "Challenge.count", "Round.count" ] do
      post admin_challenges_path, headers: @auth, params: {
        challenge: {
          location_id: locations(:yellowstone).id,
          rotation_position: 2,
          rounds_attributes: {
            "0" => { position: 1, correct_bird_id: birds(:blue_jay).id, first_distractor_id: birds(:blue_jay).id }
          }
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "fieldset.round", 5
    assert_select ".round-errors li", "Each bird in a round must be different"
  end

  test "edit form shows existing round choices" do
    get edit_admin_challenge_path(@challenge), headers: @auth

    assert_response :success
    assert_select "fieldset.round", 5
    assert_select "select[name='challenge[rounds_attributes][0][correct_bird_id]'] option[selected]", "Blue Jay"
  end

  test "updates a round's birds" do
    round = rounds(:acadia_round_2)

    patch admin_challenge_path(@challenge), headers: @auth, params: {
      challenge: {
        rounds_attributes: {
          "0" => { id: round.id, position: 2, correct_bird_id: birds(:cedar_waxwing).id }
        }
      }
    }

    assert_redirected_to admin_challenges_path
    assert_equal birds(:cedar_waxwing), round.reload.correct_bird
  end

  test "deletes a challenge and its rounds" do
    assert_difference "Challenge.count", -1 do
      assert_difference "Round.count", -5 do
        delete admin_challenge_path(@challenge), headers: @auth
      end
    end

    assert_redirected_to admin_challenges_path
  end
end
