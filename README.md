Wc2017
================

Ruby on Rails
-------------

This application requires:

- Ruby 2.3.1
- Rails 4.2.1


## TODO

- Update this to rails 5 before this grows

Getting Started
---------------

Install the gems (locally for the project):

- `bundle install --without production --path vendor/bundle`

Setup the db (once):

- `bundle exec rake db:setup`

Run the thing:

- `bundle exec rails s`


## The env file

To define the application secrets in dev mode, and define some environment values, please use the `.env` file at the application root.

Example of the content of such a file:

```
WCA_CLIENT_ID="blablabla"
WCA_CLIENT_SECRET="coucou"
```

`config/initializers/default_environment.rb` contains some default value for the development environment, they are overridable in the `.env` file.

License
-------
MIT
(See [here](https://github.com/RailsApps/rails-omniauth#mit-license), this application was based on this template)
