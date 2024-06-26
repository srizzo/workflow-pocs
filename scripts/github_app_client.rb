require 'json'
require 'octokit'
require 'openssl'
require 'jwt'
require 'base64'
require 'dotenv'
Dotenv.load('./.env.production.local')

def github_app_client
  private_key = OpenSSL::PKey::RSA.new(Base64.decode64(ENV['GITHUB_PRIVATE_KEY']))
  payload = {
    iat: Time.now.to_i - 60,
    exp: Time.now.to_i + (10 * 60),
    iss: ENV['GITHUB_APP_ID']
  }
  jwt = JWT.encode(payload, private_key, 'RS256')

  installation_client = Octokit::Client.new(bearer_token: jwt)

  installation_token = installation_client.create_app_installation_access_token(ENV['GITHUB_APP_INSTALLATION_ID'])['token']
  Octokit::Client.new(access_token: installation_token)
end
