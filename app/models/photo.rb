class Photo < ApplicationRecord
  IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  belongs_to :bird
  has_one_attached :image, dependent: :purge

  normalizes :source_url, :creator, :license_name, :license_url, with: ->(value) { value.strip }
  normalizes :attribution_notes, with: ->(value) { value.strip.presence }

  validates :source_url, :creator, :license_name, :license_url, presence: true
  validate :source_url_is_wikimedia
  validate :license_url_is_web_address
  validate :image_is_acceptable

  private

  def source_url_is_wikimedia
    return if source_url.blank?

    host = web_uri(source_url)&.host
    unless host == "wikimedia.org" || host&.end_with?(".wikimedia.org")
      errors.add(:source_url, "must be a wikimedia.org address")
    end
  end

  def license_url_is_web_address
    return if license_url.blank?

    errors.add(:license_url, "must be an http or https address") unless web_uri(license_url)
  end

  def image_is_acceptable
    if !image.attached?
      errors.add(:image, "must be attached")
    elsif !image.blob.content_type.in?(IMAGE_TYPES)
      errors.add(:image, "must be a JPEG, PNG, or WebP")
    elsif image.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be 10 MB or smaller")
    end
  end

  def web_uri(value)
    uri = URI.parse(value)
    uri if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end
end
