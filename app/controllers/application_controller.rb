class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  before_action :check_managed_competition

  private
    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

    def user_signed_in?
      return true if current_user
    end

    def correct_user?
      @user = User.find(params[:id])
      unless current_user == @user
        redirect_to root_url, :alert => "Access denied."
      end
    end

    def authenticate_user!
      if !current_user
        redirect_to root_url, :alert => 'You need to sign in for access to this page.'
      end
    end

    def redirect_unless_admin!
      unless current_user&.can_manage_competition?(managed_competition)
        redirect_to root_url, :alert => 'You need to be admin to access this page'
      end
    end

    def managed_competition
      @managed_competition ||= Competition.find_by_id(app_comp_id)
    end

    def check_managed_competition
      unless managed_competition
        begin
          competition_response = RestClient.get(wca_api_url("/competitions/#{app_comp_id}"))
          competition_data = JSON.parse(competition_response.body)
          admins = competition_data["organizers"] + competition_data["delegates"]
          obj_attr = {
            admin_ids: admins.map { |person| person["id"] }.uniq.join(",")
          }
          status, competition = Competition.create_or_update(competition_data, obj_attr)
          unless status
            return redirect_to(root_url, alert: "Failed to fetch competition info")
          end
          @managed_competition = competition
        rescue RestClient::ExceptionWithResponse => err
          redirect_to(root_url, alert: "Failed to fetch competition info")
        end
      end
    end
end
