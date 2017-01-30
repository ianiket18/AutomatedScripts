#!/bin/env ruby

require 'aws-sdk'
require 'optparse'
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
  opts.on("-h", "--help", "Help screen") do
    puts opts
    exit
  end
end.parse!

@userName = 'ianiket18' if @userName.nil?

unless ARGV[0].nil?
  query = { repoName: ARGV[0], userName: @userName}
  repo_url = find_document('ansible_project', 'repositories', query)['gitURL']

  unless repo_url
    repo_url = get_repo_link(ARGV[0], @userName)
    if repo_url
      doc = { repoName: ARGV[0], userName: @userName, gitURL: repo_url }
      mongo_insert_doc('ansible_project', 'repositories', doc)
    else
      puts "No repository found, please check details."
      exit
    end
  end
else
  puts "No repository mentioned, please check details."
  exit
end

if ARGV[1]
  playbook_contents = get_playbook(ARGV[0], @userName, ARGV[1])
else
  playbook_contents = get_playbook(ARGV[0], @userName)
end



