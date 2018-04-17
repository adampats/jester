require 'thor'
require 'pry'
require 'faraday'
require 'json'
require 'uri'

module Jester
  class Cli < Thor

    # Global options
    class_option :url, desc: "URL of Jenkins master",
      aliases: '-s', default: "http://localhost:8080"
    class_option :username, desc: "User to connect with",
      aliases: '-u', default: "admin"
    class_option :password, desc: "Password to connect with",
      aliases: '-p', default: "admin"
    class_option :debug, desc: "Toggle verbose/debug output",
      aliases: '-v', default: false, type: :boolean

    #
    desc "test", "Test Jenkins server connectivity"
    method_option :url, desc: "URL of Jenkins master",
      aliases: '-s', default: "http://localhost:8080"
    method_option :username, desc: "User to connect with",
      aliases: '-u', default: "admin"
    method_option :password, desc: "Password to connect with",
      aliases: '-p', default: "admin"
    def test
      puts "Testing authenticated connectivity to #{@options[:url]}..."
      r = get( @options[:url], @options[:username], @options[:password] )
      version = r['x-jenkins']
      if version.nil?
        puts "Fail"
      else
        puts "Success!  Running Jenkins version " + version
      end
    end

    #
    desc "new", "Create new Jenkins pipeline job"
    method_option :job_name, desc: "Pipeline job name",
      aliases: '-j', default: 'jester-test-job'
    def new
      puts "Checking if job, '#{@options[:job_name]}', already exists..."
      if job_exists?(@options[:job_name])
        puts "Job already exists!  Quit."
      else
        puts "Creating new pipeline job named #{@options[:job_name]}..."
        job_params = {
          description: @options[:job_name],
          script: '// empty job created by jester\n node {print "test"}' }
        xml = pipeline_xml(job_params)
        r = post( @options[:url] + "/createItem?name=#{@options[:job_name]}",
          @options[:username], @options[:password], xml )
        if r.status == 200
          puts "Job successfully created."
        else
          puts "Job creation failed."
        end
      end
    end

    #
    desc "build", "Build (run) a Jenkins pipeline job"
    method_option :job_name, desc: "Pipeline job name",
      aliases: '-j', default: 'jester-test-job'
    def build

    end


    private

    #
    def debug
      @options[:debug]
    end

    #
    def get (url, user, pass, params = {})
      begin
        c = Faraday.new(url: url) do |conn|
          conn.basic_auth(user, pass)
          conn.adapter Faraday.default_adapter
        end
        resp = c.get
      rescue Exception => e
        puts e.message
        return e
      end
    end

    #
    def post (url, user, pass, body, params = {})
      begin
        crumb = get_crumb(url, user, pass)
        puts "DEBUG: crumb = " + crumb if @options[:debug]
        c = Faraday.new(url: url) do |conn|
          conn.basic_auth(user, pass)
          conn.adapter Faraday.default_adapter
        end
        resp = c.post do |conn|
          conn.headers['Jenkins-Crumb'] = crumb
          conn.headers['Content-Type'] = 'application/xml'
          conn.body = body
        end
        if @options[:debug]
          puts "DEBUG: "
          pp resp.to_hash[:response_headers]
        end
        return resp
      rescue Exception => e
        puts e.message
        return e
      end
    end

    #
    def get_crumb (url, user, pass)
      p_url = URI.parse(url)
      base_url = p_url.scheme + "://" + p_url.host + ":" + p_url.port.to_s
      r = get(base_url +
        '/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)',
        user, pass )
      r.body.split(':')[1]
    end

    #
    # params = { description, script }
    def pipeline_xml (params = {})
      return %Q{<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.17">
  <description>#{params[:description]}</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.46">
    <script>#{params[:script]}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>}
    end

    #
    def job_exists? (job_name)
      job = get( @options[:url] + "/job/" + job_name,
        @options[:username], @options[:password] )
      if job.reason_phrase == "Found"
        true
      else
        false
      end
    end

  end
end
