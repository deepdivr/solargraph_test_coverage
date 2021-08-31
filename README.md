# SolargraphTestCoverage

Solargraph Plugin that provides a diagnostic reporter for unit-test coverage.

Currently there are four different diagnostics:
- Line is not covered
- Branch is not covered (With a note if it's the 'THEN' or 'ELSE' branch)
- Spec is failing (Error message will be on line 1)
- Spec cannot be found (Error message will be on line 1)


Currently expects RSpec/Rails.

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

If you are using a `spec/rails_helper.rb` file, you will need to change:
```ruby
require "spec_helper"
```

to

```ruby
require_relative "spec_helper"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solargraph_test_coverage

## Usage

With solargraph running and connected to your text editor, you should see diagnostic messages for test coverage.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deepdivr/solargraph_test_coverage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
