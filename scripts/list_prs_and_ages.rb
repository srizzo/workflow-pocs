require_relative 'github_app_client'
require 'date'

client = github_app_client

org_name = 'taskmates'

client.list_repos
# user_client = client.user

# pp user_client.repos

# user = client.user(current_user.uid)
# repos = client.repos(user.login, query: {type: ‘owner’, sort: ‘asc’})


# Get all repositories in the organization
org_repos = client.org_repos(org_name, type: 'all')

puts "Listing all open PRs and their ages for #{org_name} organization:"
puts "------------------------------------------------------------"

org_repos.each do |repo|
  begin
    # Get all open pull requests for the repository
    pulls = client.pull_requests(repo.full_name, state: 'open')

    pulls.each do |pull|
      # Calculate the age of the PR in days
      age_in_days = (Date.today - pull.created_at.to_date).to_i

      puts "Repo: #{repo.name}"
      puts "PR ##{pull.number}: #{pull.title}"
      puts "Age: #{age_in_days} days"
      puts "------------------------------------------------------------"
    end
  rescue Octokit::Error => e
    puts "Error fetching PRs for #{repo.name}: #{e.message}"
  end
end
