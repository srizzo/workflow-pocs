require_relative '../lib/github_client'

require 'dotenv'
Dotenv.load('./.env.production.local')

# GitHub App credentials
app_id = ENV['GITHUB_APP_ID']

# Read the private key
client = github_client(app_id)

# Retrieve your installations
installations = client.find_installations

installations.each do |installation|
  installation_id = installation.id
  # pp installation[:account][:login]

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

