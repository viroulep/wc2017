class VisitorsController < ApplicationController
  def index
    if current_user
      redirect_to my_registration_path
    end
  end
end
