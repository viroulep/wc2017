class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:edit, :update, :confirm]
  before_action :redirect_unless_can_edit!, except: [:index, :import_all]

  def import_all
    begin
      registrations_response = RestClient.get(wca_api_url("/competitions/#{app_comp_id}/wcif"), { Authorization: "Bearer #{session[:access_token]}"})
    rescue RestClient::ExceptionWithResponse => err
      return redirect_to(registrations_url, alert: "Failed to fetch WCA data: #{err.message}")
    end
    wcif = JSON.parse(registrations_response.body)
    imported = 0
    wcif["persons"]&.each do |json_user|
      status, user = User.create_or_update(json_user)
      json_registration = json_user["registration"]
      unless status
        Rails.logger.error "Couldn't create_or_update user #{json_user}"
      else
        if json_registration
          # Using this because params.permit will remove user/event_ids since the're not basic types
          obj_attr = {
            event_ids: json_registration["eventIds"]&.join(","),
            user: user
          }
          status, registration = Registration.wca_create_or_update(json_registration, obj_attr)
          unless status
            Rails.logger.info "Couldn't create_or_update the registration!"
          else
            imported += 1
          end
        end
      end
    end

    redirect_to(registrations_url, notice: "Imported #{imported} registrations and users successfully!")
  end

  def index
    @registrations = Registration.all.includes(:user)
  end

  def edit
    @registration = Registration.find_by_id(params[:id]) || Registration.find_by(user_id: current_user.id)
    # We're not sure any of the two exists, so use &.
    @user = @registration&.user
    @mine = (@user == current_user)
  end

  def confirm
    @registration = Registration.find_by(user_id: current_user.id)
    flash = {}
    unless @registration && @registration.accepted?
      flash[:danger] = "Your registration is not accepted, or we could not find it."
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
    @user = @registration.user
    @mine = (@user == current_user)

    # Taking care of guests
    guests = params.require(:registration).permit(:guests_attributes => [:name, :id])
    # We need to manipulate guests without saving anything right now to the db, so we:
    # - Update existing guests names (no autosaving on that)
    # - Build a nested association for new guests (same, this avoid autosaving)
    # - Compare existing guests to the "new" array of guests, and mark for destruction
    #   existing guests not in the new array.
    updated_guests = []
    guests[:guests_attributes]&.each do |gid, g|
      unless g[:name].blank?
        # Get the real object, or create a new one (no save to the db yet!!!)
        new_guest = @registration.get_guest(g[:id])
        new_guest.name = g[:name]
        updated_guests << new_guest
      end
    end
    (@registration.guests - updated_guests).map(&:mark_for_destruction)

    # Taking care of tshirt size
    details = params.require(:registration).permit(:registration_detail_attributes => [:tshirt, :staff])
    updated_details = @registration.details
    updated_details.tshirt = details[:registration_detail_attributes][:tshirt]

    # Take care of the staff boolean
    if current_user.can_manage_competition?(managed_competition)
      updated_details.staff = details[:registration_detail_attributes][:staff]
    end


    if @registration.valid?
      @registration.save!
      redirect_path = @mine ? my_registration_path : edit_registration_path(@registration)
      redirect_to redirect_path, flash: { success: "Successfully saved details" }
    else
      render :edit
    end
  end

  private
  def fail_and_redirect(message)
      redirect_to(registrations_url, alert: "Signed in failed! Error: #{message}")
  end

  def redirect_unless_can_edit!
    registration = Registration.find_by_id(params[:id]) || Registration.find_by(user_id: current_user.id)

    # This is most likely that the user hasn't a registration for the competition
    if params[:id].nil? && registration.nil?
      return
    end
    unless current_user.can_edit_registration?(managed_competition, registration)
      flash[:danger] = "Cannot edit this registration"
      redirect_to root_url
      return
    end
  end
end
