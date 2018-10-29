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
      competition_response = RestClient.get(wca_api_competitions_url(competition_id), { Authorization: "Bearer #{session[:access_token]}" })
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

  def import_wcif
    source = params.require(:source)
    wcif_string_content = ""
    case source
    when "wca"
      begin
        registrations_response = RestClient.get(wca_api_url("/competitions/#{managed_competition.id}/wcif"), { Authorization: "Bearer #{session[:access_token]}"})
        wcif_string_content = registrations_response.body
      rescue RestClient::ExceptionWithResponse => err
        return redirect_to(registrations_url, alert: "Failed to fetch WCA data: #{err.message}")
      end
    when "url"
      # We're loading remote content. It's extremely dangerous, but hopefully only rightful people have access to this
      remote_url = params.require(:wcif).require(:url)
      begin
        wcif_response = RestClient.get(remote_url)
        wcif_string_content = wcif_response.body
      rescue RestClient::ExceptionWithResponse => err
        return redirect_to(registrations_url, alert: "Failed to fetch url data: #{err.message}")
      end
    else
      raise ArgumentError.new("Only 'wca' and 'file' are supported.")
    end
    wcif = JSON.parse(wcif_string_content)

    unless managed_competition.id == wcif["id"]
      return redirect_to(competition_url, flash: { danger: "WCIF is for the wrong competition!" })
    end

    Competition.import_schedule(wcif)
    registrations_size = Registration.import_registrations(wcif)

    redirect_to(registrations_url, flash: { success: "Imported #{registrations_size} registrations and users successfully!" })
  end

  def reset
    confirmation = params.require(:delete_all).permit(:confirm)
    if confirmation[:confirm] == managed_competition.id
      Competition::MODEL_USED.each do |m|
        m.delete_all
      end
      redirect_to competition_setup_url
    else
      redirect_to competition_url, flash: { danger: "Confirmation doesn't match the competition's id!" }
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
