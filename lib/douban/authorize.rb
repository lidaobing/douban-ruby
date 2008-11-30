require'oauth/consumer'
require'rexml/document'
module Douban
class Authorize
    include Douban
    attr_reader :api_key
    attr_reader :api_secret
    attr_reader :authorize_url
    attr_reader :consumer
    attr_reader :request_token
    attr_reader :access_token
    def initialize(attributes={})
      @api_key=attributes[:api_key] ||=CONF["api_key"]
      @secret_key=attributes[:secret_key]||=CONF["secret_key"]
      @oauth_option={
        :site=>OAUTH_HOST,
        :request_token_path=>REQUEST_TOKEN_PATH,
        :access_token_path=>ACCESS_TOKEN_PATH,
        :authorize_path=>AUTHORIZE_PATH 
      }
      yield self if block_given?
      self 
    end
  
  def authorized?
    !@access_token.nil?
  end
  
  def get_authorize_url
    @consumer=OAuth::Consumer.new(@api_key,@secret_key,@oauth_option)
    @request_token=@consumer.get_request_token
    @authorzie_url=@request_token.authorize_url<<"&oauth_callback="<<MY_SITE
  end
  
  def auth
    begin
      @access_token=@request_token.get_access_token
      @access_token=OAuth::AccessToken.new OAuth::Consumer.new(@api_key,
                                                                                         @secret_key,
                                                                                         {:site=>API_HOST}),
                                                                                         @access_token.token,
                                                                                         @access_token.secret
    rescue
    #raise $!
    ensure
      yield self if block_given?
      return self
    end
  end
  
  def get(path,headers={})
   @access_token.get(path,headers)
  end

  def post(path,data="",headers={})
   @access_token.post(path,data,headers)
 end

  def put(path,body="",headers={})
   @access_token.put(path,body,headers)
  end

  def delete(path,headers={})
    @access_token.delete(path,headers)
  end

  def head(path,headers={})
    @access_token.head(path,headers)
  end

  def get_people(uid="@me")
    resp=get("/people/#{url_encode(uid)}")
    if resp.code=="200"
      atom=resp.body
      People.new(atom)
    else
      nil
    end
  end

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
      end
    friends
    else
      nil
    end
  end
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
      end
      contacts
    else
      nil
    end
  end


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
      end
      contacts
    else
      nil
    end
  end
  
  
  def search_people(q="",option={'start-index'=>1,'max-results'=>10})
    resp=get("/people/?q=#{url_encode(q)}&start-index=#{option['start-index']}&max-results=#{option['max-results']}")
    if resp.code=="200"
      results=[]
      atom=resp.body
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
      result = People.new    
        %w[id title content db:location db:uid].each do |attr|
          eval <<-RUBY
            entry.each_element("#{attr}") do |e|
              result.#{attr.split(':').pop} = e.text if e.text
            end
          RUBY
        end
        entry.each_element("link") do |e|
          result.link ||= {}
          result.link["#{e.attributes['rel']}"] = e.attributes['href']
        end
        results << result
      end
      results
    else
      nil
    end
  end
  def get_book(id="")
    if id.to_s.size >=10
      resp=get("/book/subject/isbn/#{id}")
    else
      resp=get("/book/subject/#{id}")
    end
    if resp.code=="200"
      atom=resp.body
      Book.new(atom)
    else
      nil
    end
  end
  def get_movie(id="")
    if id.to_s=~/^tt\d+/
      resp=get("/movie/subject/imdb/#{id}")
    else
      resp=get("/movie/subject/#{id}")
    end
    if resp.code=="200"
      atom=resp.body
      Movie.new(atom)
    else
      nil
    end
  end
  def get_music(id="")
    resp=get("/music/subject/#{id}")
    if resp.code=="200"
      atom=resp.body
      Music.new(atom)
    else
      nil
    end
  end
  def search_book(tag='',option={'start-index'=>1,'max-results'=>10})
    resp=get("/book/subjects?tag=#{url_encode(tag)}&start-index=#{option['start-index']}&max-results=#{option['max-results']}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      books=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        books << Book.new(entry.to_s)
      end
    else
      nil
    end
    books
  end
  def search_movie(tag='',option={'start-index'=>1,'max-results'=>10})
    resp=get("/movie/subjects?tag=#{url_encode(tag)}&start-index=#{option['start-index']}&max-results=#{option['max-results']}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      movies=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        Movies << Movie.new(entry.to_s)
      end
    else
      nil
    end
    movies
  end
  def search_music(tag='',option={'start-index'=>1,'max-results'=>10})
    resp=get("/music/subjects?tag=#{url_encode(tag)}&start-index=#{option['start-index']}&max-results=#{option['max-results']}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      music=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        music << Music.new(entry.to_s)
      end
    else
      nil
    end
    music
  end
  def get_review(id='')
    resp=get("/review/#{id}")
    if resp.code=="200"
      atom=resp.body
      Review.new(atom)
    else
      nil
    end
  end
  def get_user_reviews(user_id="@me",option={'start-index'=>1,'max-results'=>10,'orderby'=>'score'})
    resp=get("/people/#{url_encode(user_id)}/reviews?start-index=#{option['start-index']}&max-results=#{option['max-results']}&orderby=#{option['orderby']}")
    if resp.code=="200"
      atom=resp.body
      reviews=[]
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        reviews<<Review.new(entry.to_s)
      end
      reviews
    else
      nil
    end
  end
  def get_movie_reviews(subject_id,option={'start-index'=>1,'max-results'=>10,'orderby'=>'score'})
    resp=get("/movie/subject/#{url_encode(subject_id)}/reviews?start-index=#{option['start-index']}&max-results=#{option['max-results']}&orderby=#{option['orderby']}")
    if resp.code=="200"
      atom=resp.body
      reviews=[]
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        reviews<<Review.new(entry.to_s)
      end
      reviews
    else
      nil
    end
  end
  def get_music_reviews(subject_id,option={'start-index'=>1,'max-results'=>10,'orderby'=>'score'})
    resp=get("/music/subject/#{url_encode(subject_id)}/reviews?start-index=#{option['start-index']}&max-results=#{option['max-results']}&orderby=#{option['orderby']}")
    if resp.code=="200"
      atom=resp.body
      reviews=[]
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        reviews<<Review.new(entry.to_s)
      end
      reviews
    else
      nil
    end
  end
  def get_book_reviews(subject_id,option={'start-index'=>1,'max-results'=>10,'orderby'=>'score'})
    resp=get("/book/subject/#{url_encode(subject_id)}/reviews?start-index=#{option['start-index']}&max-results=#{option['max-results']}&orderby=#{option['orderby']}")
    if resp.code=="200"
      atom=resp.body
      reviews=[]
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        reviews<<Review.new(entry.to_s)
      end
      reviews
    else
      nil
    end
  end
  def delete_review(review_id="")
    resp=delete("/review/#{url_encode(review_id)}")
    if resp.code=="200"
      true
    else
      false
    end
  end
  def create_review(subject_link="",title="",content="",rating=5)
    entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
          <entry xmlns:ns0="http://www.w3.org/2005/Atom">
          <db:subject xmlns:db="http://www.douban.com/xmlns/">
          <id>#{subject_link}</id>
          </db:subject>
          <content>#{gbk_to_utf8(content)}</content>
          <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" ></gd:rating>
          <title>#{gbk_to_utf8(title)}</title>
          </entry>
          }
          resp=post("/reviews",entry,{"Content-Type" => "application/atom+xml"})
          if resp.code=="201"
            true
          else
            false
          end
        end
        def modify_review(review_id="",subject_link="",title="",content="",rating=5)
          entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
              <entry xmlns:ns0="http://www.w3.org/2005/Atom">
              <id>http://api.douban.com/review/#{review_id}</id>
              <db:subject xmlns:db="http://www.douban.com/xmlns/">
              <id>#{subject_link}</id>
              </db:subject>
              <content>#{gbk_to_utf8(content)}</content>
              <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" ></gd:rating>
              <title>#{gbk_to_utf8(title)}</title>
              </entry>
              }
            resp=put("/review/#{url_encode(review_id)}",entry,{"Content-Type" => "application/atom+xml"})
            if resp.code=="200"
              true
            else
              false
            end
          end
end
end
