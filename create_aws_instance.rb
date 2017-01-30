#!/bin/env ruby

require 'aws-sdk'
require 'optparse'
require 'http'
require_relative 'github_api'
require_relative 'mongo_connection'

include GithubConnection
include MongoConnection

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: createAWS [options]"

  opts.on("-nName", "--name=NAME", "Username to search for repo") do |n|
    @userName = n
  end

  opts.on("-pPlaybook", "--playbook=Playbook Name", "Playbook name to use to deploy") do |p|
    @playbook_name = p
  end

  opts.on("-h", "--help", "Help screen") do
    puts opts
    exit
  end
end.parse!

@userName = 'ianiket18' if @userName.nil?
unless ARGV[0].nil?
  query = { repoName: ARGV[0], userName: @userName}
  result_repo = find_document('ansible_project', 'repositories', query)
  repo_url = result_repo['gitURL'] unless result_repo.nil?

  unless repo_url
    repo_url = get_repo_link(ARGV[0], @userName)
    playbook_link = get_playbook_link(ARGV[0], @userName, @playbook_name)
    if repo_url && playbook_link
      doc = { repoName: ARGV[0], userName: @userName, gitURL: repo_url, playbookURL: playbook_link }
      mongo_insert_doc('ansible_project', 'repositories', doc)
    else
      puts "No repository or playbook found, please check details."
      exit
    end
  end
else
  puts "No repository mentioned, please check details."
  exit
end

