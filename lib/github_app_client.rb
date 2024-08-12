require 'octokit'
require 'jwt'
require 'openssl'

def github_app_client(app_id)
  private_key = OpenSSL::PKey::RSA.new(Base64.decode64(ENV['GITHUB_PRIVATE_KEY']))

  # Generate the JWT
  payload = {
    iat: Time.now.to_i,
    exp: Time.now.to_i + (10 * 60),
    iss: app_id
  }

  jwt = JWT.encode(payload, private_key, 'RS256')

  # Create an Octokit client authenticated as the GitHub App
  Octokit::Client.new(bearer_token: jwt)
end
