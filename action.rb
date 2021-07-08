require 'octokit'

repo = ENV["GITHUB_REPOSITORY"]
label = ENV["LABEL"]
expire_days = ENV["EXPIRE_DAYS"]

client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
client.auto_paginate = true

open_issues = client.list_issues(repo, { :labels => label, :state => "open" })

now = Time.new.to_i
expire_days_in_seconds = expire_days * 60 * 60 * 24

open_issues.each do |issue|
  timeline = client.issue_timeline(repo, issue.number)
  last_labeled_event = timeline.select{|event| event.event == "labeled" }.last
  past_seconds = now - last_labeled_event.created_at.to_i
  if past_seconds > expire_days_in_seconds
    client.close_issue(repo, issue.number)
  end
end
