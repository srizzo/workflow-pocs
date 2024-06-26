require_relative '../lib/github_app_installation_client'
require 'date'

client = github_app_installation_client(ENV['TASKMATES_INSTALLATION_ID'])

results = client.list_app_installation_repositories

puts "Listing open Dependabot PRs and their ages:"
puts "------------------------------------------------------------"

results[:repositories].each do |repo|
  begin
    # Get all open pull requests for the repository
    pulls = client.pull_requests(repo.full_name, state: 'open')

    dependabot_pulls = pulls.select { |pull| pull.user.login == 'dependabot[bot]' }

    dependabot_pulls.each do |pull|
      # Calculate the age of the PR in days
      age_in_days = (Date.today - pull.created_at.to_date).to_i

      puts "Repo: #{repo.name}"
      puts "PR ##{pull.number}: #{pull.title}"
      puts "Age: #{age_in_days} days"
      puts "URL: #{pull.html_url}"
      puts "------------------------------------------------------------"
    end
  rescue Octokit::Error => e
    puts "Error fetching PRs for #{repo.name}: #{e.message}"
  end
end
