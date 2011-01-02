#=douban.rb
#
# Copyright (c) 2008 Hooopo
# Written and maintained by Hooopo<hoooopo@gmail.com>
#
# Copyright (C) 2010-2011 LI Daobing <lidaobing@gmail.com>
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
#   client=Douban.authorize(apikey, secret)
#   authorize_url=client.get_authorize_url
#  NOTE:
#  Permission to access a user's data is restricted -- you can't just access
#  any user's data.  In order to access a user's data, they need to have
#  visit the authorize_url and press the 'agree' button .
#  when user has press the 'agree' button ，we use client.auth to authorize.
#	 client=client.auth
#	 puts client.authoried? #return true or false
#  Get users' info via his uid
#  #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#   people = client.get_people('hooopo')
#   people.class === People
#   people.title === hooopo
#   people.location === "长沙"
#==Install and Wiki
#  http://code.google.com/p/doubanclient-ruby/


module Douban
  autoload :Authorize, 'douban/authorize'
end
require 'douban/version'
