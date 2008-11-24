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
     doc=REXML::Document.new(atom)
    entry=doc.root.elements
    People.new(entry)
    else
    nil
  end
  
end#end of get_people
def get_friends(uid="@me",option={'start-index'=>1,'max-results'=>10})
  resp=get("/people/#{url_encode(uid)}/friends?start-index=#{option['start-index']}&max-results=#{option['max-results']}")
if resp.code=="200"
  option={}
  people=[]
atom=resp.body
doc=REXML::Document.new(atom)
elements=doc.root.elements
elements.each do |e|
      if e.name=='entry'
       people << People.new(REXML::Document.new(e))
       elsif e.name=='author'
      
       else
       option[e.name]=e.text
       end#end of if
    
    option['people']=people
    Friends.new(option)
    end #end of each
else
 nil
end#end of if
end#end of get_friends



end#end of class
end#end of moudel
