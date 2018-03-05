class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!, except: [:edit, :update, :confirm, :schedule]
  before_action :redirect_unless_can_edit!, only: [:edit, :update, :confirm]
  before_action :redirect_unless_can_view_groups!, only: [:schedule]

  WCIF_FILE_URL = "#{Rails.root}/wcif.json"

  # FIXME: somehow rename this to "import_wcif", and move it to some dedicated controller
  def import_all
    source = params.require(:source)
    wcif_string_content = ""
    case source
    when "wca"
      begin
        registrations_response = RestClient.get(wca_api_url("/competitions/#{app_comp_id}/wcif"), { Authorization: "Bearer #{session[:access_token]}"})
        wcif_string_content = registrations_response.body
      rescue RestClient::ExceptionWithResponse => err
        return redirect_to(registrations_url, alert: "Failed to fetch WCA data: #{err.message}")
      end
    when "file"
      wcif_string_content = File.read(WCIF_FILE_URL)
    else
      raise ArgumentError.new("Only 'wca' and 'file' are supported.")
    end
    wcif = JSON.parse(wcif_string_content)
    all_users = []
    all_registrations = []
    all_pb = []
    wcif["persons"]&.each do |json_user|
      json_registration = json_user.delete("registration")
      personal_bests = json_user.delete("personalBests")
      json_user = User.process_json(json_user)
      user = User.wca_new(json_user)
      if json_registration
        json_registration["event_ids"] = json_registration.delete("eventIds")&.join(",")
        unless json_registration["id"]
          json_registration["id"] = json_registration["wcaRegistrationId"]
        end
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
      ActiveRecord::Base.logger.silence do
        User.import(all_users, recursive: true)
        Registration.import(all_registrations)
      end

      Registration.where("comments ILIKE :search", search: "%staff%").each do |r|
        r.details.staff = true
        r.details.save!(validate: false)
      end
    end

    redirect_to(registrations_url, flash: { success: "Imported #{all_registrations.size} registrations and users successfully!" })
  end

  def printable_schedules
    @registrations = Registration.includes([registration_detail: [], scramble_events: [], user: [], groups: [:round], staff_registrations_groups: { group: [:round] }, staff_teams_groups: { group: [:round] }])
    @side_event = ["333mbf", "444bf", "555bf"]
    length = 30
    offset = 0
    case params[:type]
    when "staff"
      @registrations = @registrations.staff_available.sort_by(&:name)
    else
      offset = params[:off]&.to_i || 0
      @registrations = @registrations.accepted.reject { |r| r.staff? }.sort_by(&:name)
      @registrations = @registrations.slice!(offset, length)
    end
  end

  def badges
    inclusion = [ :registration_detail, :user, :guests ]
    @staff = Registration.staff_available.includes(inclusion)
    @competitors = Registration.accepted.includes(inclusion) - @staff
  end

  def cleanup
    @registrations = Registration.accepted.includes(:user, :personal_bests, :registration_detail).order(:id)
    @to_clean = {}
    @registrations.each do |r|
      r.events.each do |eid|
        e = Event.find(eid)
        type = (eid == "333mbf" || eid == "444bf" || eid == "555bf" || eid == "pyram" || eid == "333fm" || eid == "333bf" || eid == "222" || eid == "333") ? "single" : "average"
        pb = r.best_for(eid, type)
        unless pb && pb.as_solve_time < e.limit
          @to_clean[r.id] ||= []
          @to_clean[r.id] << eid
        end
      end
    end
  end

  def mails
    @registrations = {}
    @registrations[:fr] = Registration.accepted.includes(:user).where(users: { country_iso2: "FR" })
    @registrations[:en] = Registration.accepted.includes(:user).where.not(users: { country_iso2: "FR" })
  end

  def names
    @registrations = Registration.accepted.includes(:user)
  end

  def import
  end

  def psych_sheet
    @event = Event.find(params[:event_id])
    sort_column = GroupsController::SINGLE.include?(@event.id) ? "single" : "average"
    #@registrations = Registration.with_event("333", [:user, :personal_bests])
    @registrations = Registration.with_event(@event.id, [:user, :personal_bests]).sort_by do |r|
      r.best_for(@event.id, sort_column)&.as_solve_time || SolveTime::SKIPPED
    end
  end

  def top3
    @registrations = Registration.includes(:user, :personal_bests)
    @lines = []
    Event.all.each do |e|
      ["single", "average"].each do |t|
        sorted_registrations = @registrations.sort_by do |r|
          r.best_for(e.id, t)&.as_solve_time || SolveTime::SKIPPED
        end
        sorted_registrations[0..2].each do |r|
          @lines << [e.name, t, r.best_for(e.id, t), r.user.wca_id, r.name, Country.find_by_iso2(r.user.country_iso2)[:name], r.user.avatar_url]
        end
      end
    end
  end

  def index
    @registrations = Registration.all.includes(:user, :registration_detail)
  end

  def staff
    @registrations = Registration.includes(:user, :registration_detail, :scramble_events, :staff_team_members, :staff_teams).where(registration_details: { staff: true }).order(:id)
  end

  def schedule
    base_model = Registration.includes([staff_registrations_groups: { group: [:round] }, staff_teams_groups: { group: [:round] }])
    @registration = base_model.find_by_id(params[:registration_id]) || base_model.find_by(user_id: current_user.id)
    unless @registration
      return redirect_to my_registration_path
    end
    @groups = @registration.groups
    # individual schedule affectation
    @staff_registrations_groups = @registration.staff_registrations_groups.map(&:group)
    # staff schedule affectation
    @staff_groups = @registration.staff_teams_groups.map(&:group)
    side_event = ["333mbf", "444bf", "555bf"]
    @staff_groups.reject! do |g|
      side_event.include?(g.event_id) && @groups.include?(g)
    end
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
      elsif @registration.details&.cancelled_at
        flash[:warning] = "Your registration is already cancelled!"
      else
        action = params.require(:'registration-action')
        case action
        when "confirm"
          details = @registration.details
          details.confirmed_at = Time.now
          # Skip validation because we're fine with a nil tshirt size for now
          @registration.save!(validate: false)
          flash[:success] = "Successfully confirmed registration"
        when "cancel"
          details = @registration.details
          details.cancelled_at = Time.now
          # Skip validation because we're fine with a nil tshirt size for now
          @registration.save!(validate: false)
          flash[:success] = "Successfully cancelled registration"
        else
          flash[:danger] = "Unrecognized action"
        end
      end
    end
    redirect_to my_registration_path, flash: flash
  end

  def update
    @registration = Registration.find(params[:id])
    @user = @registration.user
    @mine = (@user == current_user)

    if current_user.can_edit_guests?(managed_competition)
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
    end

    permitted_details = [:mbf1, :tshirt, :restaurant_guests, :vg]
    if current_user.can_manage_competition?(managed_competition)
      permitted_details << [:staff, :runner_only, :mbf_judge]
    end
    details = params.require(:registration).permit(:registration_detail_attributes => permitted_details)
    updated_details = @registration.details
    if details["registration_detail_attributes"]
      updated_details.assign_attributes(details["registration_detail_attributes"])
    end

    scramble_events_params = params.require(:registration).permit(:scramble_events_attributes => [:id, :event_id, :_destroy])
    scramble_events = scramble_events_params[:scramble_events_attributes] || []
    if current_user.can_manage_competition?(managed_competition)
      @registration.assign_attributes(scramble_events_params)
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
