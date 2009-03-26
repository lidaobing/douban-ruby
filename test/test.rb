$:.unshift(File.dirname(__FILE__)+"/../lib")
require"pp"
require'douban'
puts Douban::API_CONF
puts Douban::CONF
pp client=Douban.authorize
puts client.get_authorize_url
puts client.authorized?
system "pause"
pp client.auth
#puts client.authorized?
pp client.get_people
