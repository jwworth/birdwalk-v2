class GameController < ApplicationController
  def show
    @challenge = Challenge.playable.order(:rotation_position).first
  end
end
