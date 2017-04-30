class StaffTeamsController < ApplicationController
  before_action :set_staff_team, only: [:show, :edit, :update, :destroy]

  # GET /staff_teams
  def index
    @staff_teams = StaffTeam.all
  end

  # GET /staff_teams/1
  def show
  end

  # GET /staff_teams/new
  def new
    @staff_team = StaffTeam.new
  end

  # GET /staff_teams/1/edit
  def edit
  end

  # POST /staff_teams
  def create
    @staff_team = StaffTeam.new(staff_team_params)

    if @staff_team.save
      flash[:success] = 'Staff team was successfully created.'
      redirect_to @staff_team
    else
      render :new
    end
  end

  # PATCH/PUT /staff_teams/1
  def update
    if @staff_team.update(staff_team_params)
      flash[:success] = 'Staff team was successfully updated.'
      redirect_to @staff_team
    else
      render :edit
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
    @staff_team = StaffTeam.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def staff_team_params
    params.require(:staff_team).permit(:name)
  end
end
