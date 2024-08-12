require 'octokit'
require 'jwt'
require 'openssl'

def github_client
  Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
end
