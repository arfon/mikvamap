require 'instagram'
require './server.rb'

task :configure do
  Instagram.configure do |config|
    config.client_id = ENV['INSTAGRAM_CLIENT_ID']
    config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
  end
end

desc 'List all subscriptions'
task subs: :configure do
  Instagram.subscriptions.each { |sub| p sub }
end

desc 'Create a Instagram tag subscription'
task create_sub: :configure do
  Instagram.create_subscription(
    'tag',
    "http://#{ENV['DOMAIN']}/callback",
    object_id: ENV['TAG'],
    verify_token: ENV['HUB_TOKEN'])
  puts "Subscription created for #{ENV['TAG']}!"
end

desc 'Delete Users'
task :delete_users_and_images do
  User.destroy_all
  Image.destroy_all
end