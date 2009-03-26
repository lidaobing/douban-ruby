#=douban.rb
#
# Copyright (c) 2008 Hooopo
# Written and maintained by Hooopo<hoooopo@gmail.com>
#
# 
# This program is free software. You can re-distribute and/or
# modify this program under the same terms of ruby itself ---
# Ruby Distribution License or GNU General Public License.
#
# See Douban::Authorize for an overview and examples. 
# 
#== Douban API Client Based Ruby
# This is the Douban Ruby library, which communicates to the Douban
# API REST servers and converts Atom into proper Ruby objects.
# In order to use the library, you need to sign up for a Douban account and
# ensure you have the oauth and modules installed.
# Douban account and ApiKey,SecrectKey
# To get a Douban account,you need to sign up at:
# http://www.douban.com/register
# Once approved, you will need to create an application to get your api key and
# secret key at :
# http://www.douban.com/service/apikey/
# You can get apikey and secrectkey ,if you create an application.
# The keys can be placed into douban.yaml or specified at runtime
# when you new a Douban::Authorize.
# Depencencies
# This library has some external dependencies:
# oauth     ( http://oauth.googlecode.com/svn/code/ruby )
# You can install oauth via rubygem:
#	Gem install oauth -y
#==Usage
#   require "douban"
#   client=Douban.authorize
#   authorize_url=client.get_authorize_url
#  NOTE:
#  Permission to access a user's data is restricted -- you can't just access
#  any user's data.  In order to access a user's data, they need to have
#  visit the authorize_url and press the 'agree' button .
#  when user has press the 'agree' button £¬we use client.auth to authorize.
#	 client=client.auth
#	 puts client.authoried? #return true or false
#  Get users' info via his uid 
#  #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#   people = client.get_people('hooopo')
#   people.class === People
#   people.title === hooopo
#   people.location === "³¤É³"
#==Install and Wiki
#  http://code.google.com/p/doubanclient-ruby/

base = File.expand_path(File.dirname(__FILE__))
$:.unshift base + "/douban"
$:.unshift base + "/douban/classes"
$:.unshift base + "/douban/helper"
%w(mail authorize people subjects reviews collections miniblogs notes events helper).each(&method(:require))
module Douban
  API_CONF     = if File.exist?("douban.conf")
                   "douban.conf"
                 elsif ENV["DOUBAN_CONF"] && File.exist?(ENV["DOUBAN_CONF"])
                   ENV["DOUBAN_CONF"]
                 else 
                   File.dirname(__FILE__)+"/douban.yaml"
                 end
  #API_CONF     =File.dirname(__FILE__)+"/douban.yaml"
  #CONF = YAML.load(File.open(API_CONF)) 
  CONF = YAML.load(File.open(API_CONF)) or {} rescue CONF = {}
  MY_SITE=CONF['mysite']
  API_HOST= "http://api.douban.com"
  OAUTH_HOST="http://www.douban.com"
  REQUEST_TOKEN_PATH ="/service/auth/request_token"
  ACCESS_TOKEN_PATH="/service/auth/access_token"
  AUTHORIZE_PATH="/service/auth/authorize"
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

