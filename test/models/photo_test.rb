require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  def build_photo(**attributes)
    Photo.new(
      bird: birds(:blue_jay),
      source_url: "https://commons.wikimedia.org/wiki/File:Blue_jay.jpg",
      creator: "Jane Birder",
      license_name: "CC BY-SA 4.0",
      license_url: "https://creativecommons.org/licenses/by-sa/4.0/",
      image: file_fixture("photo.png").open.then { |io| { io: io, filename: "photo.png" } },
      **attributes
    )
  end

  test "is valid with an image and complete licensing information" do
    assert build_photo.valid?
  end

  test "requires the source, creator, license name, and license URL" do
    photo = build_photo(source_url: "", creator: " ", license_name: nil, license_url: "")

    assert_not photo.valid?
    %i[source_url creator license_name license_url].each do |attribute|
      assert_includes photo.errors[attribute], "can't be blank"
    end
  end

  test "requires an image" do
    photo = build_photo(image: nil)

    assert_not photo.valid?
    assert_includes photo.errors[:image], "must be attached"
  end

  test "rejects files that are not JPEG, PNG, or WebP images" do
    photo = build_photo(image: { io: file_fixture("not_an_image.txt").open, filename: "not_an_image.txt" })

    assert_not photo.valid?
    assert_includes photo.errors[:image], "must be a JPEG, PNG, or WebP"
  end

  test "rejects images larger than 10 MB" do
    photo = build_photo
    photo.image.blob.byte_size = 10.megabytes + 1

    assert_not photo.valid?
    assert_includes photo.errors[:image], "must be 10 MB or smaller"
  end

  test "requires the source to be on wikimedia.org" do
    assert build_photo(source_url: "https://upload.wikimedia.org/wikipedia/commons/a/ab/Blue_jay.jpg").valid?

    [ "https://example.com/blue_jay.jpg", "https://notwikimedia.org/x", "not a url", "ftp://commons.wikimedia.org/x" ].each do |url|
      photo = build_photo(source_url: url)
      assert_not photo.valid?, "expected #{url} to be rejected"
      assert_includes photo.errors[:source_url], "must be a wikimedia.org address"
    end
  end

  test "requires the license URL to be a web address" do
    photo = build_photo(license_url: "javascript:alert(1)")

    assert_not photo.valid?
    assert_includes photo.errors[:license_url], "must be an http or https address"
  end

  test "strips whitespace and blank attribution notes" do
    photo = build_photo(creator: "  Jane Birder ", attribution_notes: "  ")

    assert_equal "Jane Birder", photo.creator
    assert_nil photo.attribution_notes
  end

  test "is destroyed with its bird" do
    bird = birds(:cedar_waxwing)
    build_photo(bird: bird).save!

    assert_difference [ "Photo.count", "ActiveStorage::Attachment.count" ], -1 do
      bird.destroy!
    end
  end
end
