require 'rubygems'
require 'douban'

class MyDouban < Douban::Authorize
  def initialize
    @apikey = '042bc009d7d4a04d0c83401d877de0e7'
    @secret = 'a9bb2d7f8cc00110'
    super(@apikey, @secret)
  end

end

douban = MyDouban.new

print "please open #{douban.get_authorize_url}\n"
print "after login, press Enter to continue\n"

gets

douban.auth
print douban.get_people
