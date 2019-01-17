class VisitorsController < ApplicationController
  def index
    @all_competitors = if managed_competition.groups_visible_for_all?
                         Registration.includes(:user).sort_by(&:name)
                       else
                         []
                       end
  end
end
