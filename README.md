# SolargraphTestCoverage

Solargraph Plugin that provides a diagnostic reporter for unit-test coverage.

Currently only works with RSpec. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solargraph_test_coverage'
```

Then add this to your `.solargraph.yml` config:
```yaml
plugins:
  - solargraph_test_coverage
reporters:
- test_coverage
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solargraph_test_coverage

## Usage

With solargraph running and connected to your text editor, you should see diagnostic messages for test coverage.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ckolkey/solargraph_test_coverage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
