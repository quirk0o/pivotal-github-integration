require 'sinatra'
require 'json'
require 'octokit'

post '/' do
  client = Octokit::Client.new(
    client_id: ENV['CLIENT_ID'],
    client_secret: ENV['CLIENT_SECRET']
  )

  payload = JSON.parse(request.body.read)
  puts payload
  content_type :json
  {key: 'value'}.to_json
end