$:.unshift(File.dirname(__FILE__)+"/../lib")
require'douban'
puts Douban::API_CONF
puts Douban::CONF
client=Douban.authorize
puts client.get_authorize_url
puts client.authorized?
