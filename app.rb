require 'sinatra'
require 'json'
require 'octokit'

'Test'

post '/' do
  client = Octokit::Client.new(
    client_id: ENV['CLIENT_ID'],
    client_secret: ENV['CLIENT_SECRET']
  )
  id = ''
  prs = client.pull_requests('quirk0o/pivotal-github-integration')
  pr = prs.find { |pr| pr[:title].match(id) }
  commits = client.pull_request_commits('quirk0o/pivotal-github-integration', pr.number)

  payload = JSON.parse(request.body.read)
  puts payload
  content_type :json
  {key: 'value'}.to_json
end