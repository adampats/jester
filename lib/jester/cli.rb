require 'thor'
require 'pry'
require 'faraday'
require 'json'
require 'uri'

module Jester
  class Cli < Thor

    # Constants
    JOB_RETRY = 2 # seconds to wait between checking build result

    # Global options
    class_option :url, desc: "URL of Jenkins master",
      aliases: '-s', default: "http://localhost:8080"
    class_option :username, desc: "User to connect with",
      aliases: '-u', default: "admin"
    class_option :password, desc: "Password to connect with",
      aliases: '-p', default: "admin"
    class_option :verbose, desc: "Toggle verbose/debug output",
      aliases: '-v', default: false, type: :boolean

    #
    desc "test", "Test Jenkins server connectivity"
    def test
      puts "Testing authenticated connectivity to #{@options[:url]}..."
      r = get( @options[:url] )
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
        r = post( @options[:url] + "/createItem?name=#{@options[:job_name]}", xml )
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
    method_option :pipeline_file, desc: "Path to ad-hoc pipeline (Jenkinsfile) file",
      aliases: '-f', default: 'Jenkinsfile'
    def build
      if File.file?(@options[:pipeline_file])
        pipeline = File.read(@options[:pipeline_file])
      else
        puts "File not found: " + @options[:pipeline_file]
        raise 'FileNotFound'
      end
      job_params = {
        description: @options[:job_name],
        script: pipeline }
      xml = pipeline_xml(job_params)

      if job_exists?(@options[:job_name])
        path = "/job/" + @options[:job_name] + "/config.xml"
      else
        path = "/createItem?name=" + @options[:job_name]
      end
      r = post( @options[:url] + path, xml )
      if r.status != 200
        puts "Job config update failed."
        quit
      else
        puts "Job config update succeeded."
      end

      build_path = "/job/" + @options[:job_name] + "/build?delay=0sec"
      build_resp = post( @options[:url] + build_path )
      if build_resp.status != 201
        puts "Unable to run build. Quit"
        quit
      else
        puts "Build running - getting output..."
      end
      resp = get(@options[:url] + "/job/" + @options[:job_name] + "/api/json")
      json = JSON.parse(resp.body)
      if json['inQueue'] == false
        build_num = json['lastBuild']['number']
      end

      build = build_result(@options[:job_name], build_num)
      puts "Job " + build_num.to_s + " result: " + build['result']
      log = log_result(@options[:job_name], build_num)
      puts "DEBUG: " + log.body if debug
      File.write("#{@options[:job_name]}.log", log.body)
      puts "See #{@options[:job_name]}.log for output."
    end


    private

    #
    def debug
      @options[:verbose]
    end

    #
    def get (url, params = {})
      begin
        c = Faraday.new(url: url) do |conn|
          conn.basic_auth(@options[:username], @options[:password])
          conn.adapter Faraday.default_adapter
        end
        resp = c.get
      rescue Exception => e
        puts e.message
        return e
      end
    end

    #
    def post (url, body = nil, params = {})
      begin
        crumb = get_crumb(url, @options[:username], @options[:password])
        puts "DEBUG: crumb = " + crumb if @options[:verbose]
        c = Faraday.new(url: url) do |conn|
          conn.basic_auth(@options[:username], @options[:password])
          conn.adapter Faraday.default_adapter
        end
        resp = c.post do |conn|
          conn.headers['Jenkins-Crumb'] = crumb
          conn.headers['Content-Type'] = 'application/xml'
          if body != nil
            conn.body = body
          end
        end
        if @options[:verbose]
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
        '/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' )
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
      job = get( @options[:url] + "/job/" + job_name )
      if job.reason_phrase == "Found"
        true
      else
        false
      end
    end

    #
    def build_result (job_name, build_number)
      result = nil
      while result.nil?
        resp = JSON.parse(
          get( @options[:url] +
            "/job/" + job_name + "/" + build_number.to_s + "/api/json").body )
        if resp['building'] == true || resp['result'].nil?
          sleep JOB_RETRY
          print "." if debug
        end
        result = resp['result']
      end
      resp
    end

    #
    def log_result (job_name, build_number)
      resp = get( @options[:url] + "/job/" + job_name + "/" + build_number.to_s + "/consoleText")
    end

  end
end
