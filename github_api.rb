require 'http'
require 'json'

@github_url = 'https://api.github.com/'
@userName = 'ianiket18'
@playbook_name = 'provision.yml'

module GithubConnection
  def get_repo_link(repo_name, userName = nil)
    userName ||= @userName
    response = HTTP.get(@github_url + 'repos/' + userName +'/' + repo_name)
    if response.status.code == 404
      false
    else
      JSON.parse(response.body.to_s)['clone_url']
    end
  end

  def get_playbook_link(repo_name, userName = nil, playbook_name = nil)
    userName ||= @userName
    playbook_name ||= @playbook_name
    puts playbook_name
    response = HTTP.get(@github_url + 'repos/' + userName + '/' + repo_name + '/contents/' + playbook_name)
    if response.status.code == 404
      false
    else
      raw_link = JSON.parse(response.body.to_s)['download_url']
    end
  end
end
