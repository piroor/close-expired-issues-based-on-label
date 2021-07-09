require 'octokit'

repo = ENV["GITHUB_REPOSITORY"]
label = ENV["LABEL"]
exception_labels = (ENV["LABEL_EXCEPTIONS"] || "").split(",").collect{|label| label.strip }
expire_days = ENV["EXPIRE_DAYS"]
p "ENV:"
pp ENV

client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
client.auto_paginate = true

p "Finding issues with a label #{label}"
open_issues = client.list_issues(repo, { :labels => label, :state => "open" })
p " => #{open_issues.size} issues found"

now = Time.new.to_i
expire_days_in_seconds = expire_days.to_i * 60 * 60 * 24

p "Checking issues with expire days #{expire_days} and exception labels #{exception_labels.join(", ")}"
open_issues.each do |issue|
  p "Issue #{issue.number} (#{issue.labels.collect{|label| label.name }.join(", ")})"
  if not exception_labels.empty? and issue.labels.any?{|label| exception_labels.any?(label.name) }
    p " => has one of exceptions #{exception_labels.join(", ")}"
    next
  end
  timeline = client.issue_timeline(repo, issue.number)
  last_labeled_event = timeline.select{|event| event.event == "labeled" }.last
  past_seconds = now - last_labeled_event.created_at.to_i
  if past_seconds > expire_days_in_seconds
    p " => close"
    #client.close_issue(repo, issue.number)
  else
    p " => not expired yet"
  end
end
