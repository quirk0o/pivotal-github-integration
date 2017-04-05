require 'sinatra'
require 'json'
require 'octokit'
require 'tracker_api'

'Test'

# TODO: add project id to url
post '/github/:pivotal_project_id' do
  pivotal_client = TrackerApi::Client.new(token: ENV['PIVOTAL_ACCESS_TOKEN'])
  github_client = Octokit::Client.new(
    access_token: ENV['ACCESS_TOKEN']
  )

  payload = JSON.parse(request.body.read)
  puts payload
  pr_number = payload['number']
  story_id = payload['pull_request']['title'].match(/(?<=#)\d+(?=\s)/).to_s

  project = pivotal_client.project(params['pivotal_project_id'])
  story = project.story(story_id)
  story_accepted = story.current_state == 'accepted'
  state = story_accepted ? 'success' : 'failure'

  commits = github_client.pull_request_commits('quirk0o/pivotal-github-integration', pr_number)
  sha = commits.last.sha
  options = {
    target_url: story.url,
    description: "Story was #{story_accepted  ? 'accepted' : 'rejected'}",
    context: 'continuous-integration/pivotal'
  }
  github_client.create_status('quirk0o/pivotal-github-integration', sha, state, options)

  status :ok
  body ''
end

post '/pivotal' do
  client = Octokit::Client.new(
    access_token: ENV['ACCESS_TOKEN']
  )

  payload = JSON.parse(request.body.read)
  puts payload
  pivotal_project_id = payload['primary_resources'].first['id']
  pivotal_project_url = payload['primary_resources'].first['url']
  resource_kind = payload['primary_resources'].first['kind']

  if resource_kind == 'story'
    accepted_at = payload['changes'].first['new_values']['accepted_at']
    puts accepted_at
    state = accepted_at ? 'success' : 'failure'
    prs = client.pull_requests('quirk0o/pivotal-github-integration')
    pr = prs.find { |pr| pr[:title].match("##{pivotal_project_id}") }
    break unless pr

    commits = client.pull_request_commits('quirk0o/pivotal-github-integration', pr.number)
    sha = commits.last.sha
    options = {
      target_url: pivotal_project_url,
      description: "Story was #{accepted_at ? 'accepted' : 'rejected'}",
      context: 'continuous-integration/pivotal'
    }
    client.create_status('quirk0o/pivotal-github-integration', sha, state, options)
  end

  status :ok
  body ''
end