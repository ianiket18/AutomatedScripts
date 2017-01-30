require 'http'
require 'json'

@github_url = 'https://api.github.com/'

module GithubConnection
  def get_repo_link(repo_name, userName = 'ianiket18')
    response = HTTP.get(@github_url + 'repos/' + userName +'/' + repo_name)
    if response.status.code == 404
      false
    else
      JSON.parse(response.body.to_s)['clone_url']
    end
  end

  def get_playbook(repo_name, userName, playbook_name = 'provision.yml')
    response = HTTP.get(@github_url + 'repos/' + userName + '/' + repo_name + '/contents/' + playbook_name)
    if response.status.code == 404
      false
    else
      raw_link = JSON.parse(response.body.to_s)['download_url']
      playbook = HTTP.get(raw_link).body.to_s
    end
  end
end
