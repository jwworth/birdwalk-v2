require "test_helper"

class RoundTest < ActiveSupport::TestCase
  setup do
    @challenge = Challenge.create!(location: locations(:yellowstone), rotation_position: 2)
  end

  test "can be saved with only some birds chosen" do
    round = @challenge.rounds.build(position: 1, correct_bird: birds(:blue_jay))

    assert round.save
    assert_not round.complete?
  end

  test "is complete when all four birds are chosen" do
    assert rounds(:acadia_round_1).complete?
  end

  test "requires a position from 1 to 5" do
    assert_not @challenge.rounds.build(position: 0).valid?
    assert_not @challenge.rounds.build(position: 6).valid?
    assert @challenge.rounds.build(position: 5).valid?
  end

  test "requires a unique position within its challenge" do
    round = challenges(:acadia).rounds.build(position: 1)

    assert_not round.valid?
    assert_includes round.errors[:position], "has already been taken"
  end

  test "requires every chosen bird to be different" do
    round = @challenge.rounds.build(position: 1, correct_bird: birds(:blue_jay), third_distractor: birds(:blue_jay))

    assert_not round.valid?
    assert_includes round.errors[:base], "Each bird in a round must be different"
  end

  test "uses the correct bird's oldest photo, breaking ties by ID" do
    round = rounds(:acadia_round_1)
    oldest = photos(:blue_jay)
    tied = round.correct_bird.photos.create!(
      oldest.slice(:source_url, :creator, :license_name, :license_url)
        .merge(image: { io: file_fixture("photo.png").open, filename: "photo.png" })
    )

    assert_equal oldest, round.reload.photo

    tied.update_column(:created_at, oldest.created_at)

    assert_equal [ oldest, tied ].min_by(&:id), round.reload.photo
  end

  test "database rejects duplicate birds in a round" do
    round = @challenge.rounds.build(position: 1, correct_bird: birds(:blue_jay), second_distractor: birds(:blue_jay))

    assert_raises ActiveRecord::StatementInvalid do
      round.save!(validate: false)
    end
  end
end
