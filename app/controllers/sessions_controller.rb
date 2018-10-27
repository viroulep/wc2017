class SessionsController < ApplicationController
  before_action only: [:anon_staff, :login_anon_staff, :new, :signin_with_wca] do
    if current_user
      redirect_to root_url, flash: { success: 'Already in' }
    end
  end

  def new
  end

  def signin_with_wca
    scopes = %w(public email dob)
    can_manage = params.require(:signin).require(:can_manage)
    if can_manage == "1"
      scopes << "manage_competitions"
    end
    session[:scopes] = scopes

    redirect_to wca_login_url(scopes.join(" "))
  end

  def anon_staff
  end

  def login_anon_staff
    if anonymous_password.blank?
      return redirect_to root_url, flash: { danger: 'Anonymous access not setup' }
    end
    anon_user = User.find(-666)
    submitted = params.require(:anon_staff).require(:password)
    if submitted == anonymous_password
      session[:user_id] = -666
      redirect_to(root_url, flash: { success: 'Signed in as anonymous!' })
    else
      redirect_to(root_url)
    end
  end

  # The WCA.org OAuth code redirects to here after user logs in
  # From here: https://github.com/larspetrus/Birdflu/blob/1a74b55c1005e3ad74c51881c06b88a9d3f3f8d7/app/controllers/oauth_controller.rb
  def create
    token_params = {
      code: params[:code],
      grant_type: 'authorization_code',
      redirect_uri: fixed_wca_callback_url,
      client_id: wca_client_id,
      client_secret: wca_client_secret,
    }
    begin
      token_response = RestClient.post(wca_token_url, token_params)
    rescue RestClient::ExceptionWithResponse => err
      return fail_and_redirect(err.response.code)
    end

    access_token = JSON.parse(token_response.body)["access_token"]

    begin
      me_response = RestClient.get(wca_api_url("/me"), { Authorization: "Bearer #{access_token}" })
    rescue RestClient::ExceptionWithResponse => err
      return fail_and_redirect(err.response.code)
    end

    me_data = JSON.parse(me_response.body)["me"]

    status, user = User.create_or_update(me_data)
    unless status
      return fail_and_redirect("Could not create or update user! (That's a pretty bad error!)")
    end
    session[:user_id] = user.id
    session[:access_token] = access_token

    Rails.logger.info "WCA Logged in as '#{me_data['name']}'."
    return_to = session.delete(:return_to) || root_path
    redirect_to(return_to, flash: { success: 'Signed in !' })
  end

  def destroy
    reset_session
    redirect_to root_url, flash: { success: 'Signed out!' }
  end

  private
  def fail_and_redirect(message)
      reset_session
      Rails.logger.info "WCA Login failed."
      redirect_to(root_url, alert: "Signed in failed! Error: #{message}")
  end
end
