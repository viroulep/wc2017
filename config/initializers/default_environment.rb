unless Rails.env.production?
  ENV["WCA_CALLBACK_URL"] ||= "http://127.0.0.1:3000/wca_callback"
  ENV["WCA_BASE_URL"] ||= "http://localhost:1234"
  # We're just testing locally
  ENV["WCA_USE_SSL"] ||= "false"
end
