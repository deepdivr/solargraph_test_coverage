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


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ckolkey/solargraph_test_coverage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
