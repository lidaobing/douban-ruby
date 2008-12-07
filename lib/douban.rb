#=douban.rb
#
# Copyright (c) 2008 Hooopo
# Written and maintained by Hooopo<wxz125627771@gmail.com>
#
# 
# This program is free software. You can re-distribute and/or
# modify this program under the same terms of ruby itself ---
# Ruby Distribution License or GNU General Public License.
#
# See Douban::Authorize for an overview and examples. 
# 
base = File.expand_path(File.dirname(__FILE__))
$:.unshift base + "/douban"
$:.unshift base + "/douban/classes"
$:.unshift base + "/douban/helper"
%w(authorize people subjects reviews collections miniblogs notes events helper).each(&method(:require))
module Douban
  API_CONF     =File.dirname(__FILE__)+"/douban.yaml"
  CONF = YAML.load(File.open(API_CONF)) 
  MY_SITE                     =CONF['mysite']
  API_HOST                   = "http://api.douban.com"
  OAUTH_HOST              ="http://www.douban.com"
  REQUEST_TOKEN_PATH ="/service/auth/request_token"
  ACCESS_TOKEN_PATH   ="/service/auth/access_token"
  AUTHORIZE_PATH         ="/service/auth/authorize"
 
  def self.authorize
    @client = Authorize.new
    yield @client if block_given?
    @client
  end
  def self.authorization
    @client ||= self.authorize
  end
end
fail "This is a library, not a command line app" if $0 == __FILE__

