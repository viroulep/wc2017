class StaffTeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_admin!
  before_action :set_staff_team, only: [:show, :edit, :update, :destroy]
  before_action :set_staff_available, only: [:edit, :update]

  # GET /staff_teams
  def index
    @staff_teams = StaffTeam.all
  end

  # GET /staff_teams/1
  def show
    @scramblers_per_event = @staff_team.scramble_events.group(:event_id).count
  end

  # GET /staff_teams/new
  def new
    @staff_team = StaffTeam.new
  end

  # GET /staff_teams/1/edit
  def edit
    @scramblers_per_event = @staff_team.scramble_events.group(:event_id).count
  end

  # POST /staff_teams
  def create
    @staff_team = StaffTeam.new(staff_team_params)

    if @staff_team.save
      flash[:success] = 'Staff team was successfully created.'
      redirect_to edit_staff_team_path(@staff_team)
    else
      render :new
    end
  end

  # PATCH/PUT /staff_teams/1
  def update
    case params[:registrations_action]
    when "add-selected"
      return add_selected_to_team
    when "remove-selected"
      return remove_selected_from_team
    when "update"
      if @staff_team.update(staff_team_params)
        flash[:success] = 'Staff team was successfully updated.'
        redirect_to edit_staff_team_path(@staff_team)
      else
        render :edit
      end
    else
      raise "Unrecognized action #{params[:registrations_action]}"
    end
  end

  # DELETE /staff_teams/1
  def destroy
    @staff_team.destroy
    flash[:success] = 'Staff team was successfully destroyed.'
    redirect_to staff_teams_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_staff_team
    @staff_team = StaffTeam.includes({ staff_team_members: { registration: [:user, :scramble_events, :registration_detail] }}).find(params[:id])
  end

  def set_staff_available
    existing_ids = @staff_team.staff_team_members.map { |m| m.registration_id }
    @staff_available = Registration.staff_available.includes(:user).reject { |r| existing_ids.include?(r.id) }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def staff_team_params
    params.require(:staff_team).permit(:name, :staff_team_members_attributes => [:id, :team_leader])
  end

  def selected_registrations_ids
    params.require(:selected_registrations).split(',').map { |r| r.split('-')[1].to_i }
  end

  def add_selected_to_team
    registration_ids = selected_registrations_ids
    existing_ids = @staff_team.staff_team_members.map { |m| m.registration_id }
    registration_ids.reject { |id| existing_ids.include?(id) }.each do |id|
      @staff_team.staff_team_members.build(registration: Registration.find(id))
    end
    if @staff_team.save
      flash[:success] = "Successfully added people to team"
    else
      flash[:danger] = "Couldn't save staff team, maybe you try to add the same person twice?"
    end
    redirect_to edit_staff_team_path(@staff_team)
  end

  def remove_selected_from_team
    registration_ids = selected_registrations_ids
    @staff_team.staff_team_members.where(registration_id: registration_ids).map(&:destroy)
    redirect_to edit_staff_team_path(@staff_team)
  end
end
