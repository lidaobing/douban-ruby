require'oauth/consumer'
require'rexml/document'
module Douban
class Authorize
  include Douban
  #attr:authorized
  attr_reader :apiKey
  attr_reader :apiSecret
  attr_reader :authorize_url
  attr_reader :consumer
  attr_reader :request_token
  attr_reader :access_token
  def initialize(attributes={})
    #@authorized=false
    @apiKey=attributes[:apiKey] ||=CONF["apiKey"]
    @secretKey=attributes[:secretKey]||=CONF["secretKey"]
    @oauthOption={
     :site=>OAUTH_HOST,
     :request_token_path=>REQUEST_TOKEN_PATH,
     :access_token_path=>ACCESS_TOKEN_PATH,
     :authorize_path=>AUTHORIZE_PATH 
    }
    
    yield self if block_given?
    self 
  end#end of initialize
  
  def authorized?
    !@access_token.nil?
  end#end of authorized?
  
  def get_authorize_url
    @consumer=OAuth::Consumer.new(@apiKey,@secretKey,@oauthOption)
    @request_token=@consumer.get_request_token
    @authorzie_url=@request_token.authorize_url<<"&oauth_callback="<<MY_SITE
  end#end of get_authorize_url
  
  def auth
    begin
@access_token=@request_token.get_access_token
@access_token=OAuth::AccessToken.new OAuth::Consumer.new(@apiKey,
                                                                                         @secretKey,
                                                                                         {:site=>API_HOST}),
                                                                                         @access_token.token,
                                                                                         @access_token.secret
    rescue
    #raise $!
  ensure
  yield self if block_given?
 return self
end
#yield self if block_given?
end#end of  auth
def get(path,headers={})
  @access_token.get(path,headers)
end#end of get
def post(path,data="",headers={})
  @access_token.post(path,data,headers)
end#end of post
def put(path,body="",headers={})
  @access_token.put(path,body,headers)
end#end of put 
def delete(path,headers={})
  @access_token.delete(path,headers)
end#end of delete
def head(path,headers={})
  @access_token.head(path,headers)
end#end of head 



def get_people(uid="@me")
  resp=get("/people/#{url_encode(uid)}")
  if resp.code=="200"
    atom=resp.body
    People.new(atom)
    else
    nil
  end
  
end#end of get_people
def get_friends(uid="@me",option={'start-index'=>1,'max-results'=>10})
  resp=get("/people/#{url_encode(uid)}/friends?start-index=#{option['start-index']}&max-results=#{option['max-results']}")
if resp.code=="200"
  friends=[]
atom=resp.body
doc=REXML::Document.new(atom)
REXML::XPath.each(doc,"//entry") do |entry|
   friend = People.new    
        %w[id title content db:location db:uid].each do |attr|
          eval <<-RUBY
            entry.each_element("#{attr}") do |e|
              friend.#{attr.split(':').pop} = e.text if e.text
            end
          RUBY
        end
        entry.each_element("link") do |e|
          friend.link ||= {}
          friend.link["#{e.attributes['rel']}"] = e.attributes['href']
        end
        friends << friend
  end#end of each
  friends
else
 nil
end#end of if
end#end of get_friends
def get_contacts(uid="@me",option={'start-index'=>1,'max-results'=>10})
    resp=get("/people/#{url_encode(uid)}/contacts?start-index=#{option['start-index']}&max-results=#{option['max-results']}")
if resp.code=="200"
  contacts=[]
atom=resp.body
doc=REXML::Document.new(atom)
REXML::XPath.each(doc,"//entry") do |entry|
   contact = People.new    
        %w[id title content db:location db:uid].each do |attr|
          eval <<-RUBY
            entry.each_element("#{attr}") do |e|
              contact.#{attr.split(':').pop} = e.text if e.text
            end
          RUBY
        end
        entry.each_element("link") do |e|
          contact.link ||= {}
          contact.link["#{e.attributes['rel']}"] = e.attributes['href']
        end
        contacts << contact
  end#end of each
  contacts
else
 nil
end#end of if
  end#end of get_contacts



end#end of class
end#end of moudel
