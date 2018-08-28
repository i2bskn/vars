# Vars

[![Build Status](https://travis-ci.org/i2bskn/vars.svg?branch=master)](https://travis-ci.org/i2bskn/vars)

`vars` is provide configuration each environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "vars"
```

And then execute:

    $ bundle

## Usage

Load configuretion and resolve templates.

```ruby
vars = Vars.new(path: "path/to/environment.yml", name: "production")
vars.rails_env # => "production"
vars.app_root  # => "/var/www/app/current"

# Create config/database.yml from template.
vars.resolve_template("config/deploy/templates/database.yml.erb", "config/database.yml")

# Create config files from templates. (config/deploy/templates/**/*)
vars.resolve_templates("config/deploy/templates", "config")
```

Example configuration file.

```yaml
default:
  rails_env: development
  app_root: /var/www/app/current
  db_host: localhost

development:
  db_host: app-development-db-01.xxx.ap-northeast-1.rds.amazonaws.com

staging:
  rails_env: staging
  db_host: app-staging-db-01.xxx.ap-northeast-1.rds.amazonaws.com

production:
  rails_env: production
  db_host: app-db-01.xxx.ap-northeast-1.rds.amazonaws.com
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/i2bskn/vars.
