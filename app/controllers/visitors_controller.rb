class VisitorsController < ApplicationController
  skip_before_action :check_managed_competition

  def index
    if current_user
      redirect_to my_registration_path
    end
  end
end
