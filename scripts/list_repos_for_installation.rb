require 'octokit'
require 'jwt'
require 'openssl'

require 'dotenv'
Dotenv.load('./.env.production.local')

# GitHub App credentials
app_id = ENV['GITHUB_APP_ID']

# Read the private key
private_key = OpenSSL::PKey::RSA.new(Base64.decode64(ENV['GITHUB_PRIVATE_KEY']))

# Generate the JWT
payload = {
  iat: Time.now.to_i,
  exp: Time.now.to_i + (10 * 60),
  iss: app_id
}

jwt = JWT.encode(payload, private_key, 'RS256')

# Create an Octokit client authenticated as the GitHub App
client = Octokit::Client.new(bearer_token: jwt)

# Retrieve your installations
installations = client.find_installations

installations.each do |installation|
  installation_id = installation.id
  pp installation[:account][:login]

  # Exchange the JWT for an installation access token
  access_token = client.create_app_installation_access_token(installation_id)[:token]

  # Create a new client authenticated as the installation
  installation_client = Octokit::Client.new(access_token: access_token)

  # List repositories accessible to the installation
  results = installation_client.list_app_installation_repositories

  # Print the repository names
  results[:repositories].each do |repo|
    pp repo[:full_name]
  end
end

