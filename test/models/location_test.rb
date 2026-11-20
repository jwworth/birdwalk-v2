require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "requires a name and state" do
    location = Location.new

    assert_not location.valid?
    assert_includes location.errors[:name], "can't be blank"
    assert_includes location.errors[:state], "can't be blank"
  end

  test "requires a unique name within a state regardless of case" do
    location = Location.new(name: "acadia national park", state: "Maine")

    assert_not location.valid?
    assert_includes location.errors[:name], "has already been taken"
  end

  test "allows the same name in a different state" do
    location = Location.new(name: "Acadia National Park", state: "Vermont")

    assert location.valid?
  end

  test "squishes extra whitespace" do
    location = Location.new(name: " Glacier   National Park ", state: " Montana ")

    assert_equal "Glacier National Park", location.name
    assert_equal "Montana", location.state
  end

  test "display name includes the state" do
    assert_equal "Acadia National Park, Maine", locations(:acadia).display_name
  end

  test "cannot be destroyed while it has a challenge" do
    location = locations(:acadia)

    assert_not location.destroy
    assert Location.exists?(location.id)
  end
end
