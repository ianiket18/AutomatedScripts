#!/bin/env ruby

require 'aws-sdk'
require 'optparse'
require 'mongo'
require_relative 'github_api'

include GithubConnection

Mongo::Logger.logger.level = ::Logger::FATAL

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
  client = Mongo::Client.new('mongodb://172.17.0.2:27017/ansible_project')
  collection = client[:repositories]
  resultRepo = collection.find( { repoName: ARGV[0], userName: @userName} ).first

  unless resultRepo
    repo_url = getRepoLink(ARGV[0], @userName)
    if repo_url
      collection = client[:repositories]
      doc = { repoName: ARGV[0], userName: @userName, gitURL: repo_url }
      result = collection.insert_one(doc)
    else
      puts "No repository found, please check details."
      exit
    end
  end
else
  puts "No repository mentioned, please check details."
  exit
end




