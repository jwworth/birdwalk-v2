require "test_helper"

class Api::ScoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = challenges(:acadia)
  end

  def answer(position, bird)
    { round_id: rounds(:"acadia_round_#{position}").id, bird_id: birds(bird).id }
  end

  def answers_choosing(*birds)
    birds.each_with_index.map { |bird, index| answer(index + 1, bird) }
  end

  def submit(answers, challenge: @challenge)
    post api_challenge_score_path(challenge), params: { answers: answers }, as: :json
  end

  def round_id(position)
    rounds(:"acadia_round_#{position}").id
  end

  test "scores all five answers correct" do
    submit answers_choosing(*[ :blue_jay ] * 5)

    assert_response :success
    json = response.parsed_body
    assert_equal 5, json["correct_count"]
    assert_equal 5, json["round_count"]
    assert_equal [ true ] * 5, json["rounds"].map { |round| round["correct"] }
  end

  test "scores all five answers incorrect" do
    submit answers_choosing(*[ :canada_jay ] * 5)

    assert_response :success
    json = response.parsed_body
    assert_equal 0, json["correct_count"]
    assert_equal [ false ] * 5, json["rounds"].map { |round| round["correct"] }
    assert_equal [ "Canada Jay" ], json["rounds"].map { |round| round.dig("selected_bird", "common_name") }.uniq
  end

  test "scores a mix of answers and returns results in round order" do
    submit answers_choosing(:blue_jay, :american_robin, :blue_jay, :canada_jay, :black_capped_chickadee).reverse

    assert_response :success
    json = response.parsed_body
    assert_equal 2, json["correct_count"]
    assert_equal [ 1, 2, 3, 4, 5 ], json["rounds"].map { |round| round["position"] }
    assert_equal (1..5).map { |position| round_id(position) }, json["rounds"].map { |round| round["id"] }
    assert_equal [ true, false, true, false, false ], json["rounds"].map { |round| round["correct"] }
  end

  test "accepts IDs sent as strings" do
    submit answers_choosing(*[ :blue_jay ] * 5).map { |answer| answer.transform_values(&:to_s) }

    assert_response :success
    assert_equal 5, response.parsed_body["correct_count"]
  end

  test "returns complete results data" do
    submit answers_choosing(:american_robin, *[ :blue_jay ] * 4)

    json = response.parsed_body
    assert_equal @challenge.id, json["id"]
    assert_equal({ "name" => "Acadia National Park", "state" => "Maine" }, json["location"])

    result = json["rounds"].first
    blue_jay = birds(:blue_jay)
    assert_equal({ "id" => birds(:american_robin).id, "common_name" => "American Robin" }, result["selected_bird"])
    assert_equal(
      { "id" => blue_jay.id, "common_name" => blue_jay.common_name,
        "scientific_name" => blue_jay.scientific_name, "fact" => blue_jay.fact },
      result["correct_bird"]
    )

    photo = photos(:blue_jay)
    assert_match %r{\Ahttp://www.example.com/rails/active_storage/blobs/}, result.dig("photo", "url")
    assert_equal(
      photo.slice(:creator, :license_name, :license_url, :source_url, :attribution_notes).stringify_keys,
      result["photo"].except("url")
    )
  end

  test "returns the same photo the game endpoint served" do
    birds(:blue_jay).photos.create!(
      photos(:blue_jay).slice(:source_url, :license_name, :license_url)
        .merge(creator: "Newer Photographer", image: { io: file_fixture("photo.png").open, filename: "photo.png" })
    )

    get api_challenge_path(@challenge)
    game_photos = response.parsed_body["rounds"].map { |round| round["photo"] }

    submit answers_choosing(*[ :blue_jay ] * 5)
    score_photos = response.parsed_body["rounds"].map { |round| round["photo"] }

    assert_equal game_photos, score_photos
    assert_equal [ photos(:blue_jay).creator ], score_photos.map { |photo| photo["creator"] }.uniq
  end

  test "rejects a missing answer" do
    submit answers_choosing(*[ :blue_jay ] * 4)

    assert_response :unprocessable_content
    assert_equal [ "Exactly 5 answers are required", "Round #{round_id(5)} was not answered" ],
      response.parsed_body["errors"]
  end

  test "rejects a round answered more than once" do
    submit answers_choosing(*[ :blue_jay ] * 4) + [ answer(1, :canada_jay) ]

    assert_response :unprocessable_content
    assert_equal [ "Round #{round_id(1)} was answered more than once", "Round #{round_id(5)} was not answered" ],
      response.parsed_body["errors"]
  end

  test "rejects too many answers" do
    submit answers_choosing(*[ :blue_jay ] * 5) + [ answer(5, :blue_jay) ]

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Exactly 5 answers are required"
  end

  test "rejects a round ID that does not exist" do
    submit answers_choosing(*[ :blue_jay ] * 4) + [ { round_id: 0, bird_id: birds(:blue_jay).id } ]

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Round 0 is not part of this challenge"
  end

  test "rejects a round from another challenge" do
    other_challenge = Challenge.create!(location: locations(:yellowstone), rotation_position: 2)
    other_round = other_challenge.rounds.create!(
      position: 5, correct_bird: birds(:blue_jay), first_distractor: birds(:canada_jay),
      second_distractor: birds(:american_robin), third_distractor: birds(:cedar_waxwing)
    )

    submit answers_choosing(*[ :blue_jay ] * 4) + [ { round_id: other_round.id, bird_id: birds(:blue_jay).id } ]

    assert_response :unprocessable_content
    assert_equal [ "Round #{other_round.id} is not part of this challenge", "Round #{round_id(5)} was not answered" ],
      response.parsed_body["errors"]
  end

  test "rejects a bird that is not one of the round's choices" do
    submit answers_choosing(:cedar_waxwing, *[ :blue_jay ] * 4)

    assert_response :unprocessable_content
    assert_equal [ "Bird #{birds(:cedar_waxwing).id} is not a choice for round #{round_id(1)}" ],
      response.parsed_body["errors"]
  end

  test "rejects a bird ID that does not exist" do
    submit [ { round_id: round_id(1), bird_id: 0 } ] + answers_choosing(*[ :blue_jay ] * 5).drop(1)

    assert_response :unprocessable_content
    assert_equal [ "Bird 0 is not a choice for round #{round_id(1)}" ], response.parsed_body["errors"]
  end

  test "rejects an answer without a bird" do
    submit [ { round_id: round_id(1) } ] + answers_choosing(*[ :blue_jay ] * 5).drop(1)

    assert_response :unprocessable_content
    assert_equal [ "Each answer must include a round_id and a bird_id" ], response.parsed_body["errors"]
  end

  test "rejects a request without answers" do
    post api_challenge_score_path(@challenge), params: {}, as: :json

    assert_response :bad_request
    assert_match(/answers/, response.parsed_body["error"])
  end

  test "rejects answers that are not a list of objects" do
    post api_challenge_score_path(@challenge), params: { answers: "blue jay" }, as: :json

    assert_response :bad_request
  end

  test "returns not found for a missing challenge" do
    post api_challenge_score_path(challenge_id: 0), params: { answers: answers_choosing(*[ :blue_jay ] * 5) }, as: :json

    assert_response :not_found
    assert_equal({ "error" => "Challenge not found" }, response.parsed_body)
  end

  test "returns not found for a challenge that is not playable" do
    rounds(:acadia_round_3).update!(third_distractor: nil)

    submit answers_choosing(*[ :blue_jay ] * 5)

    assert_response :not_found
  end
end
