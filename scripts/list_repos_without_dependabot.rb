require_relative '../lib/github_app_installation_client'

client = github_app_installation_client(ENV['TASKMATES_INSTALLATION_ID'])

results = client.list_app_installation_repositories

repos_without_dependabot = results[:repositories].reject do |repo|
  client.contents(repo.full_name, path: '.github/dependabot.yml')
rescue Octokit::NotFound
  false
end

puts "Repos without Dependabot: #{repos_without_dependabot.map(&:full_name)}"

