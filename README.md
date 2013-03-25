# redmine-reporting

A simple gem to use with rails or any ruby project to report exceptions or other messages as issues to the Redmine project management system (http://www.redmine.org).


## Installation

Add this line to your application's Gemfile:

    gem 'redmine-reporting'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install redmine-reporting

Add a initializer ```config/initializers/redmine_reporting.rb``` with the following content.

```ruby
Redmine::Reporting.configure do |config|
  config.base_url = 'https://redmine.example.net/'
  config.api_key = '012345678901234567890123456789012'
  config.project = 'your-project-identifier'
  config.tracker = 1
  config.category = 1
end
```


## Usage

If you are in a Rails project, the gem will automatically hook itself into the rack middleware and report any uncatched exception.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
