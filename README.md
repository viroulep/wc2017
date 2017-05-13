Wc2017
================

Ruby on Rails
-------------

This application requires:

- Ruby 2.4
- Rails 5.0.2

Getting Started
---------------

Install the gems (locally for the project):

- `bundle install --without production --path vendor/bundle`

Setup the db (once):

- Until we have better setup for the database config locally, you have to have a "wc2017" user with password "wca".
- `bundle exec rake db:setup`


Run the thing:

- `bundle exec rails s`

Migrating (if needed):

- `bundle exec rake db:migrate`

Rollback one migration:

- `bundle exec rake db:rollback`

Migrations status

- `bundle exec rake db:migrate:status`



## The env file

To define the application secrets in dev mode, and define some environment values, please use the `.env` file at the application root.

Example of the content of such a file:

```sh
WCA_CLIENT_ID="blablabla"
WCA_CLIENT_SECRET="coucou"
# Local url for testing
WCA_CALLBACK_URL="http://127.0.0.1:3000/wca_callback"
# Local url for the WCA website
WCA_BASE_URL="http://localhost:1234"
```

`config/initializers/default_environment.rb` contains some default value for the development environment, they are overridable in the `.env` file.

## Setting up the server

This is a summary of what I ran on an almost empty ubuntu image:
```sh
sudo apt-get update -y
sudo apt-get install nginx nodejs
sudo apt-get install postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser -s wc2017
sudo -u postgres psql
#+change password
#install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby
rvm use ruby
gem install bundler
git clone https://github.com/viroulep/wc2017.git
cd wc2017/


#This file contains the real stuff!!
#(including export of RAILS_ENV and RACK_ENV to 'production')
source .env.production

bundle install --deployment --without test development --path /home/wc2017/.bundle
bundle exec rake db:setup
```

This is what I ran to start the unicorn server:
```sh
bundle exec rake assets:clean assets:precompile;
bundle exec unicorn -D -c config/unicorn.rb &
```

## Deploying new changes

```sh
ssh wc2017@wc2017.speedcubingfrance.org wc2017/deploy.sh pull_latest rebuild_rails
```


License
-------
MIT
(See [here](https://github.com/RailsApps/rails-omniauth#mit-license), this application was based on this template)
