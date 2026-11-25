ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def create_playable_challenge(name, rotation_position:)
      challenge = Challenge.create!(location: Location.create!(name: name, state: "Test"), rotation_position: rotation_position)
      challenges(:acadia).rounds.each do |round|
        challenge.rounds.create!(round.attributes.slice("position", *Round::BIRD_COLUMNS))
      end
      challenge
    end
  end
end
