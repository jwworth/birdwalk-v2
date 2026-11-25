require "test_helper"

class Api::ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = challenges(:acadia)
  end

  test "returns a playable challenge with its location and five ordered rounds" do
    get api_challenge_path(@challenge)

    assert_response :success
    json = response.parsed_body
    assert_equal @challenge.id, json["id"]
    assert_equal({ "name" => "Acadia National Park", "state" => "Maine" }, json["location"])
    assert_equal [ 1, 2, 3, 4, 5 ], json["rounds"].map { |round| round["position"] }
    assert_equal (1..5).map { |position| rounds(:"acadia_round_#{position}").id }, json["rounds"].map { |round| round["id"] }
  end

  test "each round has four distinct choices with only an id and common name" do
    get api_challenge_path(@challenge)

    expected_ids = [ :blue_jay, :canada_jay, :american_robin, :black_capped_chickadee ].map { |name| birds(name).id }
    response.parsed_body["rounds"].each do |round|
      choices = round["choices"]
      assert_equal 4, choices.size
      assert_equal expected_ids.sort, choices.map { |choice| choice["id"] }.sort
      choices.each { |choice| assert_equal %w[common_name id], choice.keys.sort }
    end
  end

  test "includes the photo URL and attribution metadata" do
    get api_challenge_path(@challenge)

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

    get api_challenge_path(@challenge)

    assert_equal [ photos(:blue_jay).creator ], response.parsed_body["rounds"].map { |round| round.dig("photo", "creator") }.uniq
  end

  test "does not reveal the correct answer, scientific names, or facts" do
    get api_challenge_path(@challenge)

    rounds = response.parsed_body["rounds"]
    assert_equal %w[choices id photo position], rounds.flat_map(&:keys).uniq.sort
    assert_equal %w[common_name id], rounds.flat_map { |round| round["choices"].flat_map(&:keys) }.uniq.sort
    assert_not_includes response.body, birds(:blue_jay).scientific_name
    assert_not_includes response.body, birds(:blue_jay).fact
  end

  test "returns not found for a missing challenge" do
    get api_challenge_path(id: 0)

    assert_response :not_found
    assert_equal({ "error" => "Challenge not found" }, response.parsed_body)
  end

  test "returns not found for a challenge with an incomplete round" do
    rounds(:acadia_round_3).update!(third_distractor: nil)

    get api_challenge_path(@challenge)

    assert_response :not_found
  end

  test "returns not found for a challenge with fewer than five rounds" do
    rounds(:acadia_round_5).destroy!

    get api_challenge_path(@challenge)

    assert_response :not_found
  end

  test "returns not found when a correct bird has no photo" do
    rounds(:acadia_round_2).update!(correct_bird: birds(:cedar_waxwing))

    get api_challenge_path(@challenge)

    assert_response :not_found
  end
end
