module ApplicationHelper
  def managed_competition
    @managed_competition ||= Competition.first
  end

  def wca_base_url
    ENV['WCA_BASE_URL']
  end

  def wca_token_url
    "#{wca_base_url}/oauth/token"
  end

  def wca_api_url(resource)
    "#{wca_base_url}/api/v0#{resource}"
  end

  def wca_api_competitions_url(competition_id="")
    wca_api_url("/competitions/#{competition_id}")
  end

  def wca_client_id
    ENV['WCA_CLIENT_ID']
  end

  def wca_login_url(scopes)
    "#{wca_base_url}/oauth/authorize?response_type=code&client_id=#{wca_client_id}&scope=#{URI.encode(scopes)}&redirect_uri=#{fixed_wca_callback_url}"
  end

  def fixed_wca_callback_url
    wca_callback_url
  end

  def wca_client_secret
    Rails.application.secrets.wca_client_secret
  end

  def wca_registration_url(id)
    "#{wca_base_url}/registrations/#{id}/edit"
  end

  def wca_person_url(wca_id)
    "#{wca_base_url}/persons/#{wca_id}"
  end

  def link_to_with_tooltip(text, url, title, args={})
    args.merge!({
      'data-toggle': 'tooltip',
      'data-trigger': 'hover',
      title: title,
    })
    link_to(text, url, args)
  end

  def anonymous_password
    ENV['ANON_PASS']
  end

  def alert(type, content = nil, note: false, &block)
    content = capture(&block) if block_given?
    if note
      content = content_tag(:strong, "Note:") + " " + content
    end
    content_tag :div, content, class: "alert alert-#{type}"
  end

  def array_to_s(items)
    comma = ""
    str = ""
    items.each do |l|
      str += comma + l.to_s
      comma = ", "
    end
    str
  end

  def staff_teams_to_links(teams)
    array_to_s(teams.map { |team| link_to(team.name, team, target: "_blank") })
  end

  def flag_icon(iso2, html_options = {})
    html_options[:class] ||= ""
    html_options[:class] += " flag-icon flag-icon-#{iso2.downcase}"
    content_tag :span, "", html_options
  end
end
