class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  # TODO authenticate admin !

  def import_all
    begin
      registrations_response = RestClient.get(wca_api_url("/registrations/#{app_comp_id}"), { Authorization: "Bearer #{session[:access_token]}"})
    rescue RestClient::ExceptionWithResponse => err
      return redirect_to(registrations_url, alert: "Failed to fetch WCA data: #{message}")
    end
    registrations_data = JSON.parse(registrations_response.body)["registrations"]
    imported = 0
    registrations_data.each do |registration|
      status, user = User.create_or_update(registration["user"])
      unless status
        Rails.logger.error "Couldn't create_or_update user #{registration["user"]}"
      else
        # Using this because params.permit will remove user/event_ids since the're not basic types
        obj_attr = {
          event_ids: registration["event_ids"]&.join(" "),
          user: user
        }
        status, registration = Registration.create_or_update(registration, obj_attr)
        unless status
          Rails.logger.info "Couldn't create_or_update the registration!"
        else
          imported += 1
        end
      end
    end

    redirect_to(registrations_url, notice: "Imported #{imported} registrations and users successfully!")
  end

  def index
    @registrations = Registration.all.includes(:user)
  end

  private
  def fail_and_redirect(message)
      redirect_to(registrations_url, alert: "Signed in failed! Error: #{message}")
  end
end
