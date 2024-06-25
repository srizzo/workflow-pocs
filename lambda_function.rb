require 'aws-sdk-s3'
require 'json'

def lambda_handler(event:, context:)
  puts "Service gem version: #{Aws::S3::GEM_VERSION}"
  puts "Core version: #{Aws::CORE_GEM_VERSION}"
  
  puts "Received event:"
  puts JSON.pretty_generate(event)
  
  # You can add more specific logging here if needed
  
  # Return a response
  {
    statusCode: 200,
    body: JSON.generate({message: "Event logged successfully"})
  }
end
