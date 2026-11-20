module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_admin

    private

    def authenticate_admin
      username, password = admin_credentials

      authenticate_or_request_with_http_basic("BirdWalk Admin") do |given_username, given_password|
        ActiveSupport::SecurityUtils.secure_compare(given_username, username) &
          ActiveSupport::SecurityUtils.secure_compare(given_password, password)
      end
    end

    # Development and test fall back to admin/password; production must set both variables.
    def admin_credentials
      if Rails.env.local?
        [ ENV.fetch("ADMIN_USERNAME", "admin"), ENV.fetch("ADMIN_PASSWORD", "password") ]
      else
        [ ENV.fetch("ADMIN_USERNAME"), ENV.fetch("ADMIN_PASSWORD") ]
      end
    end
  end
end
