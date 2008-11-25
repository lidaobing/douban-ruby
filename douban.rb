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
require'authorize.rb'
require'people.rb'
require'helper'
module Douban
#What is this library?
#this library provides your program functions to access Douban Api Server and get or post,delete data of the Douban Website,when you have authorized.
#Examples
#
#Example1: requrie'douban'
# client=Douban.authorize
# url=client.get_authorize_url
#Example2: requrie'douban'
#Douban.authorize do |client|
#client.get_authorize_url
#end
#Example3:require'douban'
#client=Douban.authorization
#url=client.get_authorize_url
#Examle4:You may also take a block after authorizition method just as authorize
#
#When you  got the authorize_url,you may want the user to open it in his browser,and submit the 'agree' button so that your application can access his information .
#If he does that:
#client=client.auth
#people=client.get_people("ahbei")
#
#

 #please fill the douban.yaml file in douban directory with apikey and secrectkey
  API_CONF     =File.dirname(__FILE__)+"/"+"douban/douban.yaml"
            
                    
  # Load YAML configuration from a file and use those parameters  
  CONF = YAML.load(File.open(API_CONF)) 
  MY_SITE                     =CONF['mysite']
  API_HOST                   = "http://api.douban.com"
  OAUTH_HOST              ="http://www.douban.com"
  REQUEST_TOKEN_PATH ="/service/auth/request_token"
  ACCESS_TOKEN_PATH   ="/service/auth/access_token"
  AUTHORIZE_PATH         ="/service/auth/authorize"
 

  #  Authorize to Douban  Api Server
  def self.authorize
    @client = Authorize.new
    yield @client if block_given?
    @client
  end
#maybe you'll take it as the othor name of authorize method
  def self.authorization
    @client ||= self.authorize
  end
end

fail "This is a library, not a command line app" if $0 == __FILE__

