#by Hooopo
base = File.expand_path(File.dirname(__FILE__))
$:.unshift base + "/douban"
$:.unshift base + "/douban/classes"
$:.unshift base + "/douban/helper"
require'authorize.rb'
require'people.rb'
require'helper'
module Douban
#if  you set MY_SITE ,when user click the 'agree' button he will be redirect to  MY_SITE
  MY_SITE                     =""
  API_HOST                   = "http://api.douban.com"
  OAUTH_HOST              ="http://www.douban.com"
  REQUEST_TOKEN_PATH ="/service/auth/request_token"
  ACCESS_TOKEN_PATH   ="/service/auth/access_token"
  AUTHORIZE_PATH         ="/service/auth/authorize"
  #please fill the douban.yaml file in douban directory
  API_CONF     =File.dirname(__FILE__)+"/"+"douban/douban.yaml"
            
                    
  # Load YAML configuration from a file and use those parameters  
  CONF = YAML.load(File.open(API_CONF)) 

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

