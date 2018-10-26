class CompetitionsController < ApplicationController
  before_action :authenticate_user!
  # TODO: import from WCA
  before_action :redirect_if_already_setup!, only: [:setup]
  # TODO: update
  before_action :redirect_unless_admin!, only: [:show]

  skip_before_action :redirect_unless_setup!, only: [:setup]

  def show
  end


  def setup
  end

  private def redirect_if_already_setup!
    if managed_competition
      redirect_to competition_show_url, flash: { danger: "Application already setup" }
    end
  end
end
