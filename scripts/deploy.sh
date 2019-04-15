#!/usr/bin/env bash

pull_latest() {
  git pull
}

bootstrap_rails() {
  gem install bundler -v '1.16.5'
  gem install pg -v '1.0.0'
  bundle install --path=vendor/bundle
  echo "SECRET_KEY_BASE=`bin/rails secret`" >> .env.production
  bin/rails db:setup
}

setup_env() {
  read -p "Please input the WCA_CLIENT_ID for the website: " client_id
  echo "WCA_CLIENT_ID=$client_id" >> .env.production
  read -p "Please input the WCA_CLIENT_SECRET for the website: " client_secret
  echo "WCA_CLIENT_SECRET=$client_secret" >> .env.production
  echo "Bootstrap done, now please run rebuild_rails"
}

rebuild_rails() {
  bundle install
  bundle exec rake assets:clean assets:precompile
  restart_app
}

restart_app() {
  if ps -efw | grep "unicorn master" | grep -v grep; then
    # Found a unicorn master process, restart it gracefully as per
    #  http://unicorn.bogomips.org/SIGNALS.html
    pid=$(<"pids/unicorn.pid")
    kill -SIGUSR2 $pid
    sleep 5
    kill -SIGQUIT $pid
  else
    # We could not find a unicorn master process running, lets start one up!
    bundle exec unicorn -D -c config/unicorn.rb &
  fi
}

cd "$(dirname "$0")"/..

allowed_commands="pull_latest bootstrap_rails setup_env rebuild_rails restart_app"
source scripts/_parse_args.sh
