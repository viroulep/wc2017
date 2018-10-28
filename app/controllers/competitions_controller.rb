class CompetitionsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_already_setup!, only: [:setup]
  before_action :redirect_unless_admin!, only: [:show, :update]

  skip_before_action :redirect_unless_setup!, only: [:setup, :import_competition]

  def show
  end

  def update
    if managed_competition.update(settings_params)
      redirect_to competition_path, flash: { success: 'Settings updated' }
    else
      render :show
    end
  end


  def setup
    @my_competitions = []
    @error = nil
    begin
      comps_response = RestClient.get(wca_api_competitions_url, { Authorization: "Bearer #{session[:access_token]}", params: { managed_by_me: true, start: 2.days.ago} })
      @my_competitions = JSON.parse(comps_response.body)
    rescue RestClient::ExceptionWithResponse => err
      @error = err
    end
  end

  def import_competition
    competition_id = params.require(:competition_id)
    begin
      competition_response = RestClient.get(wca_api_competitions_url(competition_id))
      competition_data = JSON.parse(competition_response.body)
      admins = competition_data["organizers"] + competition_data["delegates"]
      obj_attr = {
        admin_ids: admins.map { |person| person["id"] }.uniq.join(",")
      }
      status, competition = Competition.wca_create_or_update(competition_data, obj_attr)
      unless status
        throw RestClient::ExceptionWithResponse.new
      end
      redirect_to competition_url
    rescue RestClient::ExceptionWithResponse => err
      redirect_to(competition_setup_url, alert: "Failed to fetch competition info")
    end
  end

  private def redirect_if_already_setup!
    if managed_competition
      redirect_to competition_url, flash: { danger: "Application already setup" }
    end
  end

  def settings_params
    params.require(:competition).permit([:groups_visibility])
  end
end
