require_relative '../lib/github_client'

client = github_client
client.auto_paginate = true

topic = 'dev-ex'

results = client.search_repositories("owner:lessonnine topic:#{topic}")

repos_with_topic = results[:items]

puts "Repos with '#{topic}' topic:"
pp repos_with_topic.map(&:full_name)
