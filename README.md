# Jester

[![Build Status](https://travis-ci.org/adampats/jester.svg?branch=master)](https://travis-ci.org/adampats/jester)

A command line tool to enable more seamless "local" development of Jenkinsfile groovy pipelines without having to do the typical "commit, push, webhook, pipeline job run" to iterate on a pipeline.

Instead, you can use jester, which performs the following:

 * Creates (or uses existing) pipeline job on Jenkins master
 * Updates the pipeline job's value of the pipeline script with a custom string or local Jenkinsfile
 * Runs the pipeline job with the newly modified script
 * Fetches the job console output and saves it to a local file for review

All of this is done from the command line - logging in to the Jenkins UI *not* required.

-----

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jester'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jester

-----

## Usage

If you don't have a Jenkins instance running, you can run one easily in Docker:

```
docker run -d -p 8080:8080 --name localjenkins jenkins/jenkins:lts
docker logs localjenkins
open http://localhost:8080
# perform basic setup wizard steps to bring the new Jenkins master online
```

Then you should be able to run jester using the defaults for `-s` / `--url`.

-----

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adampats/jester.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
