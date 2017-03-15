class SessionsController < ApplicationController
  require 'net/http'
  CLIENT_ID = ENV["WCA_CLIENT_ID"]
  CALLBACK_URL = ENV["WCA_CALLBACK_URL"]
  WCA_BASE_URL = ENV["WCA_BASE_URL"]
  USE_SSL = ENV["WCA_USE_SSL"]

  SCOPES = URI.escape("public email", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).freeze
  WCA_LOGIN_URL = "#{WCA_BASE_URL}/oauth/authorize?response_type=code&client_id=#{CLIENT_ID}&scope=#{SCOPES}&redirect_uri=#{CALLBACK_URL}"

  TOKEN_URI = URI.parse("#{WCA_BASE_URL}/oauth/token")
  ME_URI = URI.parse("#{WCA_BASE_URL}/api/v0/me")


  #def fake_wca_login
    #store_user_data(909, '2016FRAU99', 'Fakey McFraud', 4.hours.from_now.to_i)

    #redirect_to(:back)
  #end

  def store_user_data(id, wca_id, name, expires)
    local_db_id = WcaUser.create_or_update(id, wca_id, name)
    session[:wca_login] = { db_id: local_db_id, wca_db_id: id, wca_id: wca_id, name: name, expires: expires }
  end

  def new
    redirect_to WCA_LOGIN_URL
  end

  # The WCA.org OAuth code redirects to here after user logs in
  # From here: https://github.com/larspetrus/Birdflu/blob/1a74b55c1005e3ad74c51881c06b88a9d3f3f8d7/app/controllers/oauth_controller.rb
  def create
    token_params = {
      code: params[:code],
      grant_type: 'authorization_code',
      redirect_uri: CALLBACK_URL,
      client_id: CLIENT_ID,
      client_secret: Rails.application.secrets.wca_client_secret,
    }
    # FIXME: we may want to use something easier to use if we are to make many queries to the API
    # eg: rest-client gem
    token_response = Net::HTTP.post_form(TOKEN_URI, token_params)

    access_token = JSON.parse(token_response.body)["access_token"]

    if access_token
      me_request = Net::HTTP::Get.new(ME_URI.request_uri)
      me_request["Authorization"] = "Bearer #{access_token}"
      http = Net::HTTP.new(ME_URI.host, ME_URI.port)
      http.use_ssl = (USE_SSL == "true")
      me_data = JSON.parse(http.request(me_request).body)["me"]
      if me_data.include?(:avatar)
        me_data[:avatar_url] = me_data[:avatar][:url]
        me_data[:avatar_thumb_url] = me_data[:avatar][:thumb_url]
      end

      #store_user_data(me_data['id'], me_data['wca_id'], me_data['name'], 7.days.from_now.to_i)
      #auth = request.env["omniauth.auth"]
      #user = User.where(:uid => me_data['id'].to_s).first || User.create_with_omniauth(me_data)
      user = User.create_or_update(me_data)
      session[:user_id] = user.id

      Rails.logger.info "WCA Logged in as '#{me_data['name']}'."
      redirect_to root_url, :notice => 'Signed in !'
    else
      reset_session
      Rails.logger.info "WCA Login failed."
      redirect_to root_url, :alert => 'Signed in failed!'
      return
    end

  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
