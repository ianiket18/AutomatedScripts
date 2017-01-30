require 'http'
require 'json'

@github_url = 'https://api.github.com/'

module GithubConnection
  def getRepoLink(repo_name, userName)
    response = HTTP.get(@github_url + 'repos/' + userName +'/' + repo_name)
    if response.status.code == 404
      false
    else
      JSON.parse(response.body.to_s)['clone_url']
    end
  end

  def cloneRepo(repo_link)
  end
end
