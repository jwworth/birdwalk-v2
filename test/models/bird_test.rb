require "test_helper"

class BirdTest < ActiveSupport::TestCase
  test "is valid with a common and scientific name" do
    bird = Bird.new(common_name: "Eastern Bluebird", scientific_name: "Sialia sialis")

    assert bird.valid?
  end

  test "requires a common name and scientific name" do
    bird = Bird.new

    assert_not bird.valid?
    assert_includes bird.errors[:common_name], "can't be blank"
    assert_includes bird.errors[:scientific_name], "can't be blank"
  end

  test "requires a unique common name regardless of case" do
    bird = Bird.new(common_name: "blue jay", scientific_name: "Cyanocitta stelleri")

    assert_not bird.valid?
    assert_includes bird.errors[:common_name], "has already been taken"
  end

  test "requires a unique scientific name regardless of case" do
    bird = Bird.new(common_name: "Steller's Jay", scientific_name: "cyanocitta cristata")

    assert_not bird.valid?
    assert_includes bird.errors[:scientific_name], "has already been taken"
  end

  test "squishes extra whitespace from names" do
    bird = Bird.new(common_name: "  Eastern   Bluebird ", scientific_name: " Sialia  sialis ")

    assert_equal "Eastern Bluebird", bird.common_name
    assert_equal "Sialia sialis", bird.scientific_name
  end

  test "database rejects case-insensitive duplicate names" do
    assert_raises ActiveRecord::RecordNotUnique do
      Bird.new(common_name: "BLUE JAY", scientific_name: "Cyanocitta cristata 2").save!(validate: false)
    end
  end
end
