class VisitorsController < ApplicationController
  skip_before_action :check_managed_competition
end
