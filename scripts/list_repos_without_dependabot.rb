require_relative '../lib/github_app_installation_client'

client = github_app_installation_client(ENV['TASKMATES_INSTALLATION_ID'])

results = client.list_app_installation_repositories

repos_with_dependabot = []
repos_without_dependabot = []

results[:repositories].each do |repo|
  begin
    client.contents(repo.full_name, path: '.github/dependabot.yml')
    repos_with_dependabot << repo
  rescue Octokit::NotFound
    repos_without_dependabot << repo
  end
end

puts "Repos with Dependabot: #{repos_with_dependabot.map(&:full_name)}"
puts "Repos without Dependabot: #{repos_without_dependabot.map(&:full_name)}"


