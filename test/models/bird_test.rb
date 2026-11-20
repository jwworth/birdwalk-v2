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

  test "fact is optional" do
    bird = Bird.new(common_name: "Eastern Bluebird", scientific_name: "Sialia sialis")

    assert bird.valid?
    assert_nil bird.fact
  end

  test "squishes the fact and treats a blank fact as missing" do
    assert_equal "Males sing to defend territory.", Bird.new(fact: "  Males  sing\nto defend territory. ").fact
    assert_nil Bird.new(fact: "   ").fact
  end

  test "limits the fact to 280 characters" do
    bird = birds(:blue_jay)

    bird.fact = "a" * 280
    assert bird.valid?

    bird.fact = "a" * 281
    assert_not bird.valid?
    assert_includes bird.errors[:fact], "is too long (maximum is 280 characters)"
  end

  test "database rejects case-insensitive duplicate names" do
    assert_raises ActiveRecord::RecordNotUnique do
      Bird.new(common_name: "BLUE JAY", scientific_name: "Cyanocitta cristata 2").save!(validate: false)
    end
  end
end
