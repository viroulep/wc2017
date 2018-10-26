class ApplicationController < ActionController::Base
  include ApplicationHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  before_action :set_locale
  before_action :redirect_unless_setup!

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
        session[:return_to] ||= request.original_url
        redirect_to signin_url
      end
    end

    def redirect_unless_admin!
      unless current_user&.can_manage_competition?
        redirect_to root_url, :alert => 'You need to be admin to access this page'
      end
    end

    def redirect_unless_setup!
      unless managed_competition
        redirect_to competition_setup_url
      end
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
          status, competition = Competition.wca_create_or_update(competition_data, obj_attr)
          unless status
            return redirect_to(root_url, alert: "Failed to fetch competition info")
          end
        rescue RestClient::ExceptionWithResponse => err
          redirect_to(root_url, alert: "Failed to fetch competition info")
        end
      end
    end

    def redirect_unless_can_view_groups!
      unless (ENV['GROUPS_VISIBLE'])
        return redirect_unless_staff!
        flash[:danger] = "Groups are not yet done, or you don't have groups."
        redirect_to root_url
      end
    end

    def redirect_unless_staff!
      unless current_user&.can_manage_competition? || current_user&.registration&.details.staff
        flash[:danger] = "You can't access this page"
        redirect_to root_url
      end
    end

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def default_url_options
      { locale: I18n.locale }
    end
end
