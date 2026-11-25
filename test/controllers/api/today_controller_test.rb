require "test_helper"

class Api::TodayControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = challenges(:acadia)
  end

  test "returns today's challenge with its location, date, and five ordered rounds" do
    travel_to Time.utc(2026, 11, 25, 17) do
      get api_today_path
    end

    assert_response :success
    json = response.parsed_body
    assert_equal @challenge.id, json["id"]
    assert_equal "2026-11-25", json["date"]
    assert_equal({ "name" => "Acadia National Park", "state" => "Maine" }, json["location"])
    assert_equal [ 1, 2, 3, 4, 5 ], json["rounds"].map { |round| round["position"] }
    assert_equal (1..5).map { |position| rounds(:"acadia_round_#{position}").id }, json["rounds"].map { |round| round["id"] }
  end

  test "each round has four distinct choices with only an id and common name" do
    get api_today_path

    expected_ids = [ :blue_jay, :canada_jay, :american_robin, :black_capped_chickadee ].map { |name| birds(name).id }
    response.parsed_body["rounds"].each do |round|
      choices = round["choices"]
      assert_equal 4, choices.size
      assert_equal expected_ids.sort, choices.map { |choice| choice["id"] }.sort
      choices.each { |choice| assert_equal %w[common_name id], choice.keys.sort }
    end
  end

  test "includes the photo URL and attribution metadata" do
    get api_today_path

    photo = response.parsed_body["rounds"].first["photo"]
    fixture = photos(:blue_jay)
    assert_match %r{\Ahttp://www.example.com/rails/active_storage/blobs/}, photo["url"]
    assert_equal fixture.creator, photo["creator"]
    assert_equal fixture.license_name, photo["license_name"]
    assert_equal fixture.license_url, photo["license_url"]
    assert_equal fixture.source_url, photo["source_url"]
    assert photo.key?("attribution_notes")
  end

  test "uses the bird's oldest photo" do
    newer = birds(:blue_jay).photos.create!(
      photos(:blue_jay).attributes.slice("source_url", "creator", "license_name", "license_url")
        .merge(creator: "Newer Photographer", image: { io: file_fixture("photo.png").open, filename: "photo.png" })
    )
    assert newer.created_at > photos(:blue_jay).created_at

    get api_today_path

    assert_equal [ photos(:blue_jay).creator ], response.parsed_body["rounds"].map { |round| round.dig("photo", "creator") }.uniq
  end

  test "does not reveal the correct answer, scientific names, or facts" do
    get api_today_path

    rounds = response.parsed_body["rounds"]
    assert_equal %w[choices id photo position], rounds.flat_map(&:keys).uniq.sort
    assert_equal %w[common_name id], rounds.flat_map { |round| round["choices"].flat_map(&:keys) }.uniq.sort
    assert_not_includes response.body, birds(:blue_jay).scientific_name
    assert_not_includes response.body, birds(:blue_jay).fact
  end

  test "returns not found when no challenge is playable" do
    rounds(:acadia_round_3).update!(third_distractor: nil)

    get api_today_path

    assert_response :not_found
    assert_equal({ "error" => "No challenge is available today" }, response.parsed_body)
    assert_equal 0, DailyChallenge.count
  end

  test "changes challenge at midnight in New York during standard time" do
    second = create_playable_challenge("Zion National Park", rotation_position: 2)

    travel_to(Time.utc(2026, 11, 26, 4, 59)) { get api_today_path }
    assert_equal [ @challenge.id, "2026-11-25" ], response.parsed_body.values_at("id", "date")

    travel_to(Time.utc(2026, 11, 26, 5, 0)) { get api_today_path }
    assert_equal [ second.id, "2026-11-26" ], response.parsed_body.values_at("id", "date")
  end

  test "changes challenge at midnight in New York during daylight saving time" do
    second = create_playable_challenge("Zion National Park", rotation_position: 2)

    travel_to(Time.utc(2026, 7, 5, 3, 59)) { get api_today_path }
    assert_equal [ @challenge.id, "2026-07-04" ], response.parsed_body.values_at("id", "date")

    travel_to(Time.utc(2026, 7, 5, 4, 0)) { get api_today_path }
    assert_equal [ second.id, "2026-07-05" ], response.parsed_body.values_at("id", "date")
  end

  test "a challenge started before midnight can still be scored after midnight" do
    create_playable_challenge("Zion National Park", rotation_position: 2)

    travel_to(Time.utc(2026, 11, 26, 4, 55)) { get api_today_path }
    started = response.parsed_body
    answers = started["rounds"].map { |round| { round_id: round["id"], bird_id: round["choices"].first["id"] } }

    travel_to(Time.utc(2026, 11, 26, 5, 5)) do
      post api_challenge_score_path(started["id"]), params: { answers: answers }, as: :json
    end

    assert_response :success
    assert_equal @challenge.id, response.parsed_body["id"]
  end
end
