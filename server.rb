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
      user = User.find_by_instagram_id(user_id)
      @client = Instagram.client(:access_token => user.access_token)
      text = @client.user_recent_media[0]
      user.images.create(:data => text)
      user.green!
      TWILIO_CLIENT.account.messages.create(
        :from => ENV['TWILIO_FROM'],
        :to => user.phone_number,
        :body => "Thanks for checking in!"
      )
    end
  end
end