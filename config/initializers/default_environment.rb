# Some default values
# These can be overriden in '.env' to specify a local server for example
# FIXME: change this to the prod url when we're live
ENV["WCA_CALLBACK_URL"] ||= "http://127.0.0.1:3000/wca_callback"
ENV["WCA_BASE_URL"] ||= "https://www.worldcubeassociation.org"
ENV["WCA_COMP_ID"] ||= "ItalianChampionship2017"
ENV["GROUPS_VISIBLE"] ||= "true"
ENV["ANON_PASS"] ||= ""
