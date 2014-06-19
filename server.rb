require 'sinatra'
require 'instagram'
require 'mongo_mapper'

class Image
  include MongoMapper::Document
  
  key :data, Hash
  timestamps!
  
end

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

get '/' do
  'Hi!'
end

# Verifies subscription (http://instagram.com/developer/realtime/)
get '/callback' do
  request['hub.challenge'] if request['hub.verify_token'] == ENV['HUB_TOKEN']
end

# Receive subscription (http://instagram.com/developer/realtime/)
post '/callback' do
  begin
    process_subscription(request.body.read, env['HTTP_X_HUB_SIGNATURE'])
  rescue Instagram::InvalidSignature
    halt 403
  end
end

# Do magic...
def process_subscription(body, signature)
  fail Instagram::InvalidSignature unless signature

  Instagram.process_subscription(body, signature: signature) do |handler|
    handler.on_user_changed do |user_id, data|
      # do something
    end
  end
end