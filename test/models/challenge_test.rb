require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  test "requires a positive whole rotation position" do
    challenge = Challenge.new(location: locations(:yellowstone))

    [ nil, 0, -1, 1.5 ].each do |position|
      challenge.rotation_position = position
      assert_not challenge.valid?, "expected #{position.inspect} to be invalid"
    end
  end

  test "requires a unique rotation position" do
    challenge = Challenge.new(location: locations(:yellowstone), rotation_position: 1)

    assert_not challenge.valid?
    assert_includes challenge.errors[:rotation_position], "has already been taken"
  end

  test "allows only one challenge per location" do
    challenge = Challenge.new(location: locations(:acadia), rotation_position: 2)

    assert_not challenge.valid?
    assert_includes challenge.errors[:location_id], "already has a challenge"
  end

  test "is playable with five complete rounds" do
    challenge = challenges(:acadia)

    assert challenge.playable?
    assert_includes Challenge.playable, challenge
  end

  test "is not playable when a round is incomplete" do
    challenge = challenges(:acadia)
    rounds(:acadia_round_3).update!(third_distractor: nil)

    assert_not challenge.reload.playable?
    assert_equal 4, challenge.complete_round_count
    assert_not_includes Challenge.playable, challenge
  end

  test "is not playable with fewer than five rounds" do
    challenge = challenges(:acadia)
    rounds(:acadia_round_5).destroy!

    assert_not challenge.reload.playable?
    assert_not_includes Challenge.playable, challenge
  end

  test "can be saved without any rounds" do
    challenge = Challenge.create!(location: locations(:yellowstone), rotation_position: 2)

    assert_not challenge.playable?
    assert_not_includes Challenge.playable, challenge
  end

  test "builds missing rounds in positions 1 through 5" do
    challenge = Challenge.new(location: locations(:yellowstone), rotation_position: 2)
    challenge.rounds.build(position: 3)

    challenge.build_missing_rounds

    assert_equal [ 1, 2, 3, 4, 5 ], challenge.rounds.map(&:position).sort
  end

  test "skips new rounds with no birds chosen" do
    challenge = Challenge.create!(
      location: locations(:yellowstone),
      rotation_position: 2,
      rounds_attributes: [
        { position: 1, correct_bird_id: birds(:blue_jay).id },
        { position: 2, correct_bird_id: "", first_distractor_id: "", second_distractor_id: "", third_distractor_id: "" }
      ]
    )

    assert_equal [ 1 ], challenge.rounds.map(&:position)
  end

  test "destroys its rounds" do
    assert_difference "Round.count", -5 do
      challenges(:acadia).destroy!
    end
  end
end
