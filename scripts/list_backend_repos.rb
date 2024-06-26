require_relative '../lib/github_app_installation_client'

client = github_app_installation_client(ENV['SRIZZO_INSTALLATION_ID'])
client.auto_paginate = true

results = client.list_app_installation_repositories

repos_with_backend_tag = results[:repositories].select do |repo|
  begin
    topics = client.topics(repo.full_name)[:names]
    topics.include?('backend')
  rescue Octokit::NotFound
    false
  end
end

puts "Repos with 'backend' tag: #{repos_with_backend_tag.map(&:full_name)}"
