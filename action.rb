require 'octokit'

repo = ENV["GITHUB_REPOSITORY"]
label = ENV["LABEL"]
exception_label = ENV["EXCEPTION_LABEL"]
expire_days = ENV["EXPIRE_DAYS"]

client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
client.auto_paginate = true

open_issues = client.list_issues(repo, { :labels => label, :state => "open" })

now = Time.new.to_i
expire_days_in_seconds = expire_days.to_i * 60 * 60 * 24

open_issues.each do |issue|
  if exception_label and issue.labels.any?{|label| label.name == exception_label }
    next
  end
  timeline = client.issue_timeline(repo, issue.number)
  last_labeled_event = timeline.select{|event| event.event == "labeled" }.last
  past_seconds = now - last_labeled_event.created_at.to_i
  if past_seconds > expire_days_in_seconds
    client.close_issue(repo, issue.number)
  end
end
