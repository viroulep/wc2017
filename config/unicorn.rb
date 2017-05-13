# frozen_string_literal: true

dir = File.expand_path(File.dirname(__FILE__) + "/..")
working_directory dir

allowed_environments = {
  'production' => true,
}
rack_env = ENV['RACK_ENV']
if !allowed_environments[rack_env]
  raise "Unrecognized RACK_ENV: #{rack_env}, must be one of #{allowed_environments.keys.join ', '}"
end

stderr_path "#{dir}/log/unicorn-#{rack_env}.log"
stdout_path "#{dir}/log/unicorn-#{rack_env}.log"

worker_processes((Etc.nprocessors * 2).ceil)

listen "/tmp/unicorn.wca.sock"
pid "#{dir}/pids/unicorn.pid"

timeout 60

preload_app true

before_fork do |_server, _worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |_server, _worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
