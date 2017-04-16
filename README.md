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
WCA_USE_SSL="false"
```

`config/initializers/default_environment.rb` contains some default value for the development environment, they are overridable in the `.env` file.

License
-------
MIT
(See [here](https://github.com/RailsApps/rails-omniauth#mit-license), this application was based on this template)
