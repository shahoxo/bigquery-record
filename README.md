# BigQueryRecord

BigQueryRecord ORM!

## Installation

```ruby
gem 'bigquery-record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bigquery-record

## Usage

```
export BIGQUERY_RECORD_PROJECT="your_project_name"
export BIGQUERY_RECORD_DATASET="test"
export BIGQUERY_RECORD_EMAIL="you@developer.gserviceaccount.com"
export BIGQUERY_KEY_PATH="/path/to/your_key.p12"
```

```ruby
class ActionLog < BigQueryRecord::Base
  enum action_type: { login: 1, sell_item: 2 }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bigquery-record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

