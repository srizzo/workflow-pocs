require_relative '../lib/github_app_installation_client'
require 'octokit'

def update_workflow_file(client, repo_full_name)
  workflow_path = '.github/workflows/app_managed.yml'
  reference_workflow_path = File.join(File.dirname(__FILE__), '..', 'managed_workflows', 'app_managed.yml')
  reference_content = File.read(reference_workflow_path)

  begin
    # Check if the file exists in the repo
    file_content = client.contents(repo_full_name, path: workflow_path)
    current_content = Base64.decode64(file_content.content)

    if current_content == reference_content
      puts "Workflow file in #{repo_full_name} is up to date."
      return
    end
  rescue Octokit::NotFound
    puts "Workflow file not found in #{repo_full_name}. Creating it."
  end

  # Update or create the file
  client.create_contents(
    repo_full_name,
    workflow_path,
    "chore: update workflow files",
    reference_content,
    branch: 'main'
  )
  puts "Updated workflow file in #{repo_full_name}."
end

client = github_app_installation_client(ENV['SRIZZO_INSTALLATION_ID'])
client.auto_paginate = true

# results = client.list_app_installation_repositories

# repos_with_backend_tag = results[:repositories].select do |repo|
#   begin
#     topics = client.topics(repo.full_name)[:names]
#     topics.include?('backend')
#   rescue Octokit::NotFound
#     false
#   end
# end

puts "Updating workflow files for repos with 'backend' tag:"
# repos_with_backend_tag.each do |repo|
#   puts "Processing #{repo.full_name}..."
#   update_workflow_file(client, repo.full_name)
# end

update_workflow_file(client, "srizzo/workflow-pocs")

puts "Finished updating workflow files."
