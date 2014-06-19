require 'sinatra'
require 'instagram'
require 'mongo_mapper'
require 'active_support'
require 'redis'

class Image
  include MongoMapper::Document

  key :location, Hash
  key :images, Hash
  key :user, Hash
  key :data, Hash
  
  timestamps!

end

$redis = Redis.new(:url => ENV['REDISTOGO_URL'])

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

Instagram.configure do |config|
  config.client_id = ENV['INSTAGRAM_CLIENT_ID']
  config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
end

get '/' do
  'Hi!'
end

get '/map' do
  erb :map, :locals => { :images => Image.all, :min_tag_id => $redis.get 'min_tag_id' }
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
    handler.on_tag_changed do |tag_id, _|
      return if tag_id != ENV['TAG']
      min_tag_id = $redis.get 'min_tag_id'
      
      if min_tag_id
        medias = Instagram.tag_recent_media(tag_id, 'min_tag_id' => min_tag_id)
      else
        medias = Instagram.tag_recent_media(tag_id)
      end
      
      min_tag_id = medias.pagination[:min_tag_id]
      $redis.set('min_tag_id', min_tag_id) if min_tag_id
      medias.each do |media|
        next unless media.location
        Image.create(:data => media, :location => media.location, :images => media.images, :user => media.user)
      end
    end
  end
  "Done"
end