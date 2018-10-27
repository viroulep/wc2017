class CompetitionsController < ApplicationController
  before_action :authenticate_user!
  # TODO: import from WCA
  before_action :redirect_if_already_setup!, only: [:setup]
  before_action :redirect_unless_admin!, only: [:show, :update]

  skip_before_action :redirect_unless_setup!, only: [:setup]

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
  end

  private def redirect_if_already_setup!
    if managed_competition
      redirect_to competition_show_url, flash: { danger: "Application already setup" }
    end
  end

  def settings_params
    params.require(:competition).permit([:groups_visibility])
  end
end
