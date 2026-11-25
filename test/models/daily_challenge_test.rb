require "test_helper"

class DailyChallengeTest < ActiveSupport::TestCase
  setup do
    @acadia = challenges(:acadia)
    @day = Date.new(2026, 11, 25)
  end

  def featured_ids(days)
    days.map { |date| DailyChallenge.featured_on(date).challenge_id }
  end

  test "features nothing when no challenge is playable" do
    rounds(:acadia_round_1).update!(correct_bird: nil)

    assert_nil DailyChallenge.featured_on(@day)
    assert_equal 0, DailyChallenge.count
  end

  test "features the first playable challenge immediately" do
    assert_equal @acadia, DailyChallenge.featured_on(@day).challenge
  end

  test "repeats a single challenge every day" do
    assert_equal [ @acadia.id ] * 10, featured_ids(@day..(@day + 9))
  end

  test "cycles through challenges in rotation order and wraps around" do
    third = create_playable_challenge("Zion National Park", rotation_position: 30)
    second = create_playable_challenge("Yosemite National Park", rotation_position: 20)

    assert_equal [ @acadia, second, third, @acadia, second, third, @acadia ].map(&:id), featured_ids(@day..(@day + 6))
  end

  test "excludes incomplete challenges from the rotation" do
    second = create_playable_challenge("Yosemite National Park", rotation_position: 2)
    Challenge.create!(location: locations(:yellowstone), rotation_position: 3)

    assert_equal [ @acadia, second, @acadia ].map(&:id), featured_ids(@day..(@day + 2))
  end

  test "repeated requests on the same day return the same saved challenge" do
    create_playable_challenge("Yosemite National Park", rotation_position: 2)

    first = DailyChallenge.featured_on(@day)

    assert_no_difference -> { DailyChallenge.count } do
      assert_equal first, DailyChallenge.featured_on(@day)
      assert_equal first, DailyChallenge.featured_on(@day)
    end
  end

  test "adding a challenge during the day does not change today's challenge" do
    DailyChallenge.featured_on(@day)
    @acadia.update!(rotation_position: 5)
    create_playable_challenge("Zion National Park", rotation_position: 1)

    assert_equal @acadia, DailyChallenge.featured_on(@day).challenge
  end

  test "a challenge added during the day joins the rotation the next day" do
    DailyChallenge.featured_on(@day)
    newcomer = create_playable_challenge("Zion National Park", rotation_position: 2)

    assert_equal @acadia, DailyChallenge.featured_on(@day).challenge
    assert_equal newcomer, DailyChallenge.featured_on(@day + 1).challenge
    assert_equal @acadia, DailyChallenge.featured_on(@day + 2).challenge
  end

  test "advances by calendar days when several days pass without visitors" do
    second = create_playable_challenge("Yosemite National Park", rotation_position: 2)
    third = create_playable_challenge("Zion National Park", rotation_position: 3)
    DailyChallenge.featured_on(@day)

    assert_equal third, DailyChallenge.featured_on(@day + 2).challenge
    assert_equal second, DailyChallenge.featured_on(@day + 7).challenge
  end

  test "picks again when today's challenge stops being playable" do
    second = create_playable_challenge("Yosemite National Park", rotation_position: 2)
    third = create_playable_challenge("Zion National Park", rotation_position: 3)
    DailyChallenge.featured_on(@day)
    assert_equal second, DailyChallenge.featured_on(@day + 1).challenge

    second.rounds.first.update!(third_distractor: nil)

    assert_equal third, DailyChallenge.featured_on(@day + 1).challenge
    assert_equal 2, DailyChallenge.count
  end

  test "continues from yesterday's challenge after it leaves the rotation" do
    second = create_playable_challenge("Yosemite National Park", rotation_position: 2)
    third = create_playable_challenge("Zion National Park", rotation_position: 3)
    DailyChallenge.featured_on(@day)
    DailyChallenge.featured_on(@day + 1)

    second.rounds.first.update!(third_distractor: nil)

    assert_equal third, DailyChallenge.featured_on(@day + 2).challenge
  end

  test "today uses the calendar day in New York" do
    travel_to Time.utc(2026, 11, 26, 4, 59) do
      assert_equal Date.new(2026, 11, 25), DailyChallenge.today.date
    end
    travel_to Time.utc(2026, 11, 26, 5, 0) do
      assert_equal Date.new(2026, 11, 26), DailyChallenge.today.date
    end
  end

  test "the database allows only one challenge per date" do
    DailyChallenge.create!(date: @day, challenge: @acadia)

    assert_raises ActiveRecord::RecordNotUnique do
      DailyChallenge.create!(date: @day, challenge: @acadia)
    end
  end

  test "uses the challenge already saved by a simultaneous request" do
    second = create_playable_challenge("Yosemite National Park", rotation_position: 2)
    DailyChallenge.create!(date: @day, challenge: second)

    assert_equal second, DailyChallenge.featured_on(@day).challenge
    assert_equal 1, DailyChallenge.count
  end

  test "deleting a challenge removes its featured days" do
    DailyChallenge.featured_on(@day)

    assert_difference -> { DailyChallenge.count }, -1 do
      @acadia.destroy!
    end
  end
end
