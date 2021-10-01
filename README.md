# SolargraphTestCoverage

Solargraph Plugin that provides a diagnostic reporter for unit-test coverage.

Currently there are four different diagnostics:
- Line is not covered
- Branch is not covered (With a note if it's the 'THEN' or 'ELSE' branch)
- Spec is failing (Error message will be on line 1)
- Spec cannot be found (Error message will be on line 1)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solargraph_test_coverage', require: false
```

Then add this to your `.solargraph.yml` config:

```yaml
plugins:
  - solargraph_test_coverage
reporters:
  - test_coverage
```

Additionally, a `test_coverage` key can be added to `.solargraph.yml`. The default values are shown below:

```yaml
test_coverage:
  preload_rails: true
  test_framework: rspec # or minitest
  coverage:
    - line
    - branch
    - test_failing
    - test_missing
  exclude_paths:
    - 'app/controller'
    - 'concerns'
```



And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solargraph_test_coverage
    
A note on testing framework:
Since both Minitest and RSpec are supported, neither are direct dependencies of this gem. Therefore, you have to have them installed separately either via your bundle or via `gem install`.

## Usage

With solargraph running and connected to your text editor, you should see diagnostic messages for line coverage, branch coverage, test file presence, and test status (if it's failing)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deepdivr/solargraph_test_coverage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
