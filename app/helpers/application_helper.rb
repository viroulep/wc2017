module ApplicationHelper
  def app_comp_id
    ENV['WCA_COMP_ID']
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

  def wca_client_id
    ENV['WCA_CLIENT_ID']
  end

  def wca_login_url(scopes)
    "#{wca_base_url}/oauth/authorize?response_type=code&client_id=#{wca_client_id}&scope=#{URI.encode(scopes)}&redirect_uri=#{ENV['WCA_CALLBACK_URL']}"
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
      str += comma + l
      comma = ", "
    end
    str
  end
end
