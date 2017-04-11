class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:mine, :update, :confirm]

  def import_all
    begin
      registrations_response = RestClient.get(wca_api_url("/competitions/#{app_comp_id}/registrations"), { Authorization: "Bearer #{session[:access_token]}"})
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
          event_ids: registration["event_ids"]&.join(","),
          user: user
        }
        status, registration = Registration.wca_create_or_update(registration, obj_attr)
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

  def show
    @registration = Registration.find(params[:id])
  end

  def mine
    @registration = Registration.find_by(user_id: current_user.id)
  end

  def confirm
    @registration = Registration.find_by(user_id: current_user.id)
    flash = {}
    unless @registration
      flash[:danger] = "Could not find your registration to confirm it!"
    else
      if @registration.details&.confirmed_at
        flash[:warning] = "Your registration is already confirmed!"
      else
        details = @registration.details
        details.confirmed_at = Time.now
        # Skip validation because we're fine with a nil tshirt size for now
        @registration.save!(validate: false)
        flash[:success] = "Successfully saved details"
      end
    end
    redirect_to my_registration_path, flash: flash
  end

  def update
    @registration = Registration.find(params[:id])
    unless current_user.can_edit_registration?(managed_competition, @registration)
      flash[:danger] = "Cannot edit this registration"
      redirect_to root_url
      return
    end
    guests = params.require(:registration).permit(:guests_attributes => [:name, :id])
    updated_guests = []
    guests[:guests_attributes]&.each do |gid, g|
      unless g[:name].blank?
        new_guest = Guest.find_by(id: g[:id], registration_id: @registration.id) || Guest.new
        new_guest.name = g[:name]
        updated_guests << new_guest
      end
    end
    @registration.guests = updated_guests
    details = params.require(:registration).permit(:registration_detail_attributes => [:tshirt])
    updated_details = @registration.details
    updated_details.tshirt = details[:registration_detail_attributes][:tshirt]

    if @registration.valid?
      @registration.save!
      redirect_to my_registration_path, flash: { success: "Successfully saved details" }
    else
      render :mine
    end
  end

  private
  def fail_and_redirect(message)
      redirect_to(registrations_url, alert: "Signed in failed! Error: #{message}")
  end
end
