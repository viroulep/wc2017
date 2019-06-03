class VisitorsController < ApplicationController
  def index
    @all_competitors = Registration.includes(:user).sort_by(&:name)
  end
end
