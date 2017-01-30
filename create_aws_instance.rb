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

  unless result_repo
    repo_url = get_repo_link(ARGV[0], @userName)
    playbook_link = get_playbook_link(ARGV[0], @userName, @playbook_name)
    if repo_url && playbook_link
      result_repo = { repoName: ARGV[0], userName: @userName, gitURL: repo_url, playbookURL: playbook_link }
      mongo_insert_doc('ansible_project', 'repositories', result_repo)
    else
      puts "No repository or playbook found, please check details."
      exit
    end
  end
else
  puts "No repository mentioned, please check details."
  exit
end

repo_url = result_repo['gitURL']
playbook_url = result_repo['playbookURL']

playbook_contents = HTTP.get(playbook_url).body.to_s

ec2 = Aws::EC2::Resource.new(region: 'us-east-1')

instance = ec2.create_instances({
  image_id: 'ami-e13739f6',
  min_count: 1,
  max_count: 1,
  key_name: 'hw5',
  security_group_ids: ['sg-71bf680c'],
  instance_type: 't2.micro',
  placement: {
    availability_zone: 'us-east-1b'
  },
})

# Wait for the instance to be created, running, and passed status checks
ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance[0].id]})


puts instance[0].id
puts instance[0].public_ip_address
