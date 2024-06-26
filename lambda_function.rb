require 'json'
require 'base64'
require 'octokit'
require 'openssl'
require 'jwt'
require 'aws-sdk-dynamodb'

def lambda_handler(event:, context:)
  # Parse the incoming GitHub webhook payload
  body = JSON.parse(event['body'])

  # Log the event type
  puts "Received GitHub event: #{event['headers']['X-GitHub-Event']}"

  # Log the full payload
  puts "Payload: #{body.to_json}"

  # Decode the base64-encoded private key
  private_key = Base64.decode64(ENV['GITHUB_PRIVATE_KEY'])

  # Set up Octokit client with JWT authentication
  app_id = ENV['GITHUB_APP_ID'] # Make sure to set this in your Lambda environment variables
  client = create_jwt_client(app_id, private_key)

  # Use the client to get information about the authenticated app
  app_info = client.app

  puts "Authenticated as GitHub App: #{app_info.name}"

  # Persist the payload to DynamoDB
  persist_to_dynamodb(event, body)

  # Return a response
  {
    statusCode: 200,
    body: JSON.generate({
                          message: "GitHub event processed and persisted successfully",
                          app_name: app_info.name
                        })
  }
end

def create_jwt_client(app_id, private_key)
  private_key = OpenSSL::PKey::RSA.new(private_key)

  # Generate the JWT
  payload = {
    # issued at time, 60 seconds in the past to allow for clock drift
    iat: Time.now.to_i - 60,
    # JWT expiration time (10 minute maximum)
    exp: Time.now.to_i + (10 * 60),
    # GitHub App's identifier
    iss: app_id
  }

  jwt = JWT.encode(payload, private_key, "RS256")

  # Create an Octokit client with the JWT
  Octokit::Client.new(bearer_token: jwt)
end

def persist_to_dynamodb(event_type, payload)
  dynamodb = Aws::DynamoDB::Client.new(region: 'eu-central-1')

  item = {
    id: SecureRandom.uuid,
    event_type: event_type,
    payload: payload.to_json,
    timestamp: Time.now.to_i
  }

  dynamodb.put_item({
    table_name: 'github-webhooks',
    item: item
  })
rescue Aws::DynamoDB::Errors::ServiceError => e
  puts "Error writing to DynamoDB: #{e.message}"
end
