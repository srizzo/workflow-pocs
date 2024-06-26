require_relative 'github_app_client'

client = github_app_client

org_name = 'taskmates'

org_repos = client.org_repos(org_name, type: 'all')

repos_without_dependabot = org_repos.reject do |repo|
  client.contents(repo.full_name, path: '.github/dependabot.yml')
rescue Octokit::NotFound
  false
end

puts "Repos without Dependabot: #{repos_without_dependabot.map(&:full_name)}"

