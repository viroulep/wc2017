class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:edit, :update, :confirm]
  before_action :redirect_unless_can_edit!

  # FIXME: somehow rename this to "import_wcif", and move it to some dedicated controller
  def import_all
    begin
      registrations_response = RestClient.get(wca_api_url("/competitions/#{app_comp_id}/wcif"), { Authorization: "Bearer #{session[:access_token]}"})
    rescue RestClient::ExceptionWithResponse => err
      return redirect_to(registrations_url, alert: "Failed to fetch WCA data: #{err.message}")
    end
    wcif = JSON.parse(registrations_response.body)
    all_users = []
    all_registrations = []
    all_pb = []
    imported = 0
    wcif["persons"]&.each do |json_user|
      json_registration = json_user.delete("registration")
      personal_bests = json_user.delete("personalBests")
      json_user = User.process_json(json_user)
      user = User.wca_new(json_user)
      if json_registration
        json_registration["event_ids"] = json_registration.delete("eventIds")&.join(",")
        json_registration["user_id"] = json_user["id"]
        json_registration.delete("guests")
        all_registrations << Registration.wca_new(json_registration)
      end
      personal_bests&.each do |json_pb|
        user.personal_bests.build(PersonalBest.attrs_from_json(json_pb))
      end
      all_users << user
    end
    if all_users.any?
      # Checking everything all the time is long, let's just clear the table...
      User.delete_all
      Registration.delete_all
      PersonalBest.delete_all
      User.import(all_users, recursive: true)
      Registration.import(all_registrations)
    end

    redirect_to(registrations_url, notice: "Imported #{imported} registrations and users successfully!")
  end

  def psych_sheet
    @event = Event.find(params[:event_id])
    sort_column = GroupsController::SINGLE.include?(@event.id) ? "single" : "average"
    #@registrations = Registration.with_event("333", [:user, :personal_bests])
    @registrations = Registration.with_event(@event.id, [:user, :personal_bests]).sort_by do |r|
      r.best_for(@event.id, sort_column)&.as_solve_time || SolveTime::SKIPPED
    end
  end

  def index
    @registrations = Registration.all.includes(:user, :registration_detail)
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
