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

Install the gem via:

```sh
gem install jester
```


## Usage

If you don't have a Jenkins instance running, you can run one easily in Docker:

```sh
docker run -d -p 8080:8080 --name localjenkins jenkins/jenkins:lts
docker logs localjenkins
open http://localhost:8080
# <Basic setup wizard steps to bring the new Jenkins master online>
#   It's recommended you create a user of admin:admin for simplicity.
```

Then you should be able to run jester using the defaults for `-s` / `--url`.

**Run Jester**

Command usage:

```
Commands:
  jester build           # Build (run) a Jenkins pipeline job
  jester help [COMMAND]  # Describe available commands or one specific command
  jester new             # Create new Jenkins pipeline job
  jester test            # Test Jenkins server connectivity
  jester version         # Output version of jester

Options:
  -s, [--url=URL]                  # URL of Jenkins master
                                   # Default: http://localhost:8080
  -u, [--username=USERNAME]        # User to connect with
                                   # Default: admin
  -p, [--password=PASSWORD]        # Password to connect with
                                   # Default: admin
  -v, [--verbose], [--no-verbose]  # Toggle verbose/debug output

```

Run your local pipeline on Jenkins (assuming defaults, like Jenkins running on localhost:8080):

```sh
$ jester test
Testing authenticated connectivity to http://localhost:8080...
Success!  Running Jenkins version 2.121.3

$ jester build -f Jenkinsfile.example
Job config update succeeded.
Build running - getting output...
Job 1 result: SUCCESS
See jester-test-job.log for output.

$ cat jester-test-job.log
Started by user admin
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/jester-test-job
[Pipeline] {
[Pipeline] echo
hello world!
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

Rinse and repeat...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adampats/jester.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
