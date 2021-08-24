require 'octokit'

repo = ENV["GITHUB_REPOSITORY"]
label = ENV["LABEL"]
exception_labels = (ENV["EXCEPTION_LABELS"] || "").split(",").collect{|label| label.strip }
expire_days = ENV["EXPIRE_DAYS"] || 0
extend_days_by_reopened = ENV["EXTEND_DAYS_BY_REOPENED"] || expire_days
extend_days_by_commented = ENV["EXTEND_DAYS_BY_COMMENTED"] || expire_days
comment = ENV["COMMENT"] || "This issue has been closed due to no response within #{expire_days} days after labeled as \"#{label}\", #{extend_days_by_reopened} days after last reopened, and #{extend_days_by_commented} days after last commented."

client = Octokit::Client.new(:access_token => ENV["GITHUB_TOKEN"])
client.auto_paginate = true

p "Finding issues with a label #{label}"
open_issues = client.list_issues(repo, { :labels => label, :state => "open" })
p " => #{open_issues.size} issues found"

now = Time.new.to_i
expire_days_in_seconds = expire_days.to_i * 60 * 60 * 24
extend_days_by_reopened_in_seconds = extend_days_by_reopened.to_i * 60 * 60 * 24
extend_days_by_commented_in_seconds = extend_days_by_commented.to_i * 60 * 60 * 24

p "Checking issues with expire days #{expire_days} and exception labels #{exception_labels.join(", ")}"
open_issues.each do |issue|
  p "Issue #{issue.number} (#{issue.labels.collect{|label| label.name }.join(", ")})"
  if not exception_labels.empty? and issue.labels.any?{|label| exception_labels.any?(label.name) }
    p " => has one of exceptions #{exception_labels.join(", ")}"
    next
  end
  timeline = client.issue_timeline(repo, issue.number)


  last_labeled_event = timeline.select{|event| event.event == "labeled" }.last
  if last_labeled_event and now - last_labeled_event.created_at.to_i <= expire_days_in_seconds
    p " => not expired yet (from last labeled)"
    next
  end

  last_reopened_event = timeline.select{|event| event.event == "reopened" }.last
  if last_reopened_event and now - last_reopened_event.created_at.to_i <= extend_days_by_reopened_in_seconds
    p " => not expired yet (from reopened after expired)"
    next
  end

  last_commented_event = timeline.select{|event| event.event == "commented" and event.user.type != "Bot" }.last
  if last_commented_event and now - last_commented_event.created_at.to_i <= extend_days_by_commented_in_seconds
    p " => not expired yet (from last commented)"
    next
  end

  p " => close"
  client.close_issue(repo, issue.number)
  client.add_comment(repo, issue.number, comment)
end
