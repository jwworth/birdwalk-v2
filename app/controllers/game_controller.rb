class GameController < ApplicationController
  def show
    @challenge = Challenge.playable.order(:rotation_position).first
    @challenge_date = Time.find_zone!("America/New_York").today
  end
end
