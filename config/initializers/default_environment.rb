# Some default values
# These can be overriden in '.env' to specify a local server for example
# FIXME: change this to the prod url when we're live
ENV["WCA_CALLBACK_URL"] ||= "http://127.0.0.1:3000/wca_callback"
ENV["WCA_BASE_URL"] ||= "https://www.worldcubeassociation.org"
ENV["WCA_USE_SSL"] ||= "true"
ENV["WCA_COMP_ID"] ||= "WC2017"