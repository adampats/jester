# Jester

[![Build Status](https://travis-ci.org/adampats/jester.svg?branch=master)](https://travis-ci.org/adampats/jester)

A command line tool to enable more seamless "local" development of Jenkinsfile groovy pipelines without having to do the typical "commit, push, webhook, pipeline job run" to iterate on a pipeline.

Instead, you can use jester, which performs the following:

 * foo

Todo:
 * X rip out jenkins_api_client
 * X add generic REST methods
 * X update existing methods until tests pass
 * X implement new() method
 * implement job runner method
 * get log output method(s)
 * implement update() method


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jester'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jester

## Usage

TODO: Write usage instructions here

```
docker run -d -p 8080:8080 --name localjenkins jenkins/jenkins:lts
docker logs localjenkins
open http://localhost:8080
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jester.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
