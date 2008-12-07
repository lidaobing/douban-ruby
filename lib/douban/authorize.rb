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
    resp=get("/people/#{url_encode(uid.to_s)}")
    if resp.code=="200"
      atom=resp.body
      People.new(atom)
    else
      nil
    end
  end

  def get_friends(uid="@me",option={:start_index=>1,:max_results=>10})
    resp=get("/people/#{url_encode(uid.to_s)}/friends?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      friends=[]
      atom=resp.body
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        friends << People.new(entry.to_s)
      end
    friends
    else
      nil
    end
  end
  def get_contacts(uid="@me",option={:start_index=>1,:max_results=>10})
    resp=get("/people/#{url_encode(uid.to_s)}/contacts?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      contacts=[]
      atom=resp.body
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        contacts << People.new(entry.to_s)
      end
      contacts
    else
      nil
    end
  end


  def get_contacts(uid="@me",option={:start_index=>1,:max_results=>10})
    resp=get("/people/#{url_encode(uid.to_s)}/contacts?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      contacts=[]
      atom=resp.body
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        contacts << People.new(entry.to_s)
      end
      contacts
    else
      nil
    end
  end
  
  
  def search_people(q=nil,option={:start_index=>1,:max_results=>10})
    resp=get("/people/?q=#{url_encode(q.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      results=[]
      atom=resp.body
      doc=REXML::Document.new(atom)
      REXML::XPath.each(doc,"//entry") do |entry|
        results << People.new(entry.to_s)
      end
      results
    else
      nil
    end
  end
  def get_book(id=nil)
    if id.to_s.size >=10
      resp=get("/book/subject/isbn/#{url_encode(id.to_s)}")
    else
      resp=get("/book/subject/#{url_encode(id.to_s)}")
    end
    if resp.code=="200"
      atom=resp.body
      Book.new(atom)
    else
      nil
    end
  end
  def get_movie(id=nil)
    if id.to_s=~/^tt\d+/
      resp=get("/movie/subject/imdb/#{url_encode(id.to_s)}")
    else
      resp=get("/movie/subject/#{url_encode(id.to_s)}")
    end
    if resp.code=="200"
      atom=resp.body
      Movie.new(atom)
    else
      nil
    end
  end
  def get_music(id=nil)
    resp=get("/music/subject/#{url_encode(id.to_s)}")
    if resp.code=="200"
      atom=resp.body
      Music.new(atom)
    else
      nil
    end
  end
  def search_book(tag=nil,option={:start_index=>1,:max_results=>10})
    resp=get("/book/subjects?tag=#{url_encode(tag.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      books=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        books << Book.new(entry.to_s)
      end
      books
    else
      nil
    end

  end
  def search_movie(tag=nil,option={:start_index=>1,:max_results=>10})
    resp=get("/movie/subjects?tag=#{url_encode(tag.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      movies=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        Movies << Movie.new(entry.to_s)
      end
      movies
    else
      nil
    end
  end
  def search_music(tag='',option={:start_index=>1,:max_results=>10})
    resp=get("/music/subjects?tag=#{url_encode(tag)}&start-index=#{option['start-index']}&max-results=#{option['max-results']}")
    if resp.code=="200"
      atom=resp.body
      doc=REXML::Document.new(atom)
      music=[]
      REXML::XPath.each(doc,"//entry") do |entry|
        music << Music.new(entry.to_s)
      end
      music
    else
      nil
    end
  end
  def get_review(id=nil)
    resp=get("/review/#{url_encode(id.to_s)}")
    if resp.code=="200"
      atom=resp.body
      Review.new(atom)
    else
      nil
    end
  end
  def get_user_reviews(user_id="@me",option={:start_index=>1,:max_results=>10,:orderby=>'score'})
    resp=get("/people/#{url_encode(user_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
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
  def get_movie_reviews(subject_id=nil,option={:start_index=>1,:max_results=>10,:orderby=>'score'})
    resp=get("/movie/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
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
  def get_music_reviews(subject_id=nil,option={:start_index=>1,:max_results=>10,:orderby=>'score'})
    resp=get("/music/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
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
  def get_book_reviews(subject_id,option={:start_index=>1,:max_results=>10,:orderby=>'score'})
    resp=get("/book/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
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
  def delete_review(review_id=nil)
    resp=delete("/review/#{url_encode(review_id.to_s)}")
    if resp.code=="200"
      true
    else
      false
    end
  end
  def create_review(subject_link=nil,title=nil,content=nil,rating=5)
    entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
          <entry xmlns:ns0="http://www.w3.org/2005/Atom">
          <db:subject xmlns:db="http://www.douban.com/xmlns/">
          <id>#{subject_link}</id>
          </db:subject>
          <content>#{content}</content>
          <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" ></gd:rating>
          <title>#{title}</title>
          </entry>
          }
          resp=post("/reviews",gbk_to_utf8(entry),{"Content-Type" => "application/atom+xml"})
          if resp.code=="201"
            true
          else
            false
          end
        end
        def modify_review(review_id=nil,subject_link=nil,title=nil,content=nil,rating=5)
          entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
              <entry xmlns:ns0="http://www.w3.org/2005/Atom">
              <id>http://api.douban.com/review/#{review_id}</id>
              <db:subject xmlns:db="http://www.douban.com/xmlns/">
              <id>#{subject_link}</id>
              </db:subject>
              <content>#{content}</content>
              <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" ></gd:rating>
              <title>#{title}</title>
              </entry>
              }
            resp=put("/review/#{url_encode(review_id)}",gbk_to_utf8(entry),{"Content-Type" => "application/atom+xml"})
            if resp.code=="200"
              true
            else
              false
            end
          end
        def get_collection(collection_id=nil)
          resp=get("/collection/#{url_encode(collection_id.to_s)}")
          if resp.code=="200"
            atom=resp.body
            Collection.new(atom)
          else
            nil
          end
        end
        def get_user_collection(user_id="@me",option={
                                                        :cat=>'',
                                                        :tag=>'',
                                                        :status=>'',
                                                        :start_index=>1,
                                                        :max_results=>10,
                                                        :updated_max=>'',
                                                        :updated_min=>''
                                                      }
                                            )
          resp=get("/people/#{url_encode(user_id.to_s)}/collection?cat=#{option[:cat]}&tag=#{option[:tag]}&status=#{option[:status]}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&updated-max=#{option[:updated_max]}&updated-min=#{option[:updated_min]}")
          if resp.code=="200"
            atom=resp.body
            doc=REXML::Document.new(atom)
            author=REXML::XPath.first(doc,"//feed/author")
            author=Author.new(author.to_s) if author
            title=REXML::XPath.first(doc,"//feed/title")
            title=title.text if title
            collections=[]
            REXML::XPath.each(doc,"//entry") do |entry|
              collection=Collection.new(entry.to_s)
              collection.author=author
              collection.title=title
              collections<<collection
            end
            collections
          else
            nil
          end
        end
        def create_collection( subject_id=nil,content=nil,rating=5,status=nil,tag=[],option={ :privacy=>"public"})
                                                  
          db_tag=""
          if tag.size==0
            db_tag='<db:tag name="" />'
          else
            tag.each do |t|
              db_tag+='<db:tag name="'+t.to_s+'" />'
            end
          end
          entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
          <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
          <db:status>#{status}</db:status>
         #{db_tag}
          <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" />
          <content>#{content}</content>
          <db:subject>
          <id>#{subject_id}</id>
          </db:subject>
          <db:attribute name="privacy">#{option[:privacy]}</db:attribute>
          </entry>
          }
          resp=post("/collection",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
          if resp.code=="201"
            true
          else
            false
          end
        end
        def modify_collection(collection_id=nil,subject_id=nil,content=nil,rating=5,tag=[],status=nil,option={:privacy=>"public"})
              db_tag=""
          if tag.size==0
            db_tag='<db:tag name="" />'
          else
            tag.each do |t|
              db_tag+='<db:tag name="'+t.to_s+'" />'
            end
          end
          entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
          <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
          <id>http://api.douban.com/collection/#{collection_id}</id>
          <db:status>#{status}</db:status>
          
         #{db_tag}
          <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{rating}" />
          <content>#{content}</content>
          <db:subject>
          <id>#{subject_id}</id>
          </db:subject>
          <db:attribute name="privacy">#{option[:privacy]}</db:attribute>
          </entry>
          }
          resp=put("/collection/#{url_encode(collection_id.to_s)}",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
          if resp.code=="200"
            true
          else
            false
          end
        end
        def delete_collection(collection_id=nil)
          resp=delete("/collection/#{url_encode(collection_id.to_s)}")
          if resp.code=="200"
            true
          else
            false
          end
        end
        def get_user_miniblog(user_id="@me",option={:start_index=>1,:max_results=>10})
          resp=get("/people/#{url_encode(user_id.to_s)}/miniblog?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
          if resp.code=="200"
            atom=resp.body
            doc=REXML::Document.new(atom)
            author=REXML::XPath.first(doc,"//feed/author")
            author=Author.new(author.to_s) if author
            miniblogs=[]
            REXML::XPath.each(doc,"//feed/entry") do |entry|
              miniblog=Miniblog.new(entry.to_s)
              miniblog.author=author
              miniblogs<<miniblog
            end
            miniblogs
          else
            nil
          end
        end
        def get_user_contact_miniblog(user_id="@me",option={:start_index=>1,:max_results=>10})
            resp=get("/people/#{url_encode(user_id.to_s)}/miniblog/contacts?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
          if resp.code=="200"
            atom=resp.body
            doc=REXML::Document.new(atom)
            miniblogs=[]
            REXML::XPath.each(doc,"//feed/entry") do |entry|
              miniblog=Miniblog.new(entry.to_s)
              miniblogs<<miniblog
            end
            miniblogs
          else
            nil
          end
        end
        def create_miniblog(content=nil)
          entry=%Q{<?xml version='1.0' encoding='UTF-8'?><entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/"><content>#{content.to_s}</content></entry>}
          resp=post("/miniblog/saying",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
          if resp.code=="201"
            true
          else
            false
          end
        end
        def delete_miniblog(miniblog_id=nil)
          resp=delete("/miniblog/#{url_encode(miniblog_id.to_s)}")
          if resp.code=="200"
            true
          else
            false
          end
        end
        def get_note(note_id=nil)
          resp=get("/note/#{url_encode(note_id.to_s)}")
          if resp.code=="200"
            atom=resp.body
            Note.new(atom)
          else
            nil
          end
        end
        def get_user_notes(user_id="@me",option={:start_index=>1,:max_results=>10})
          resp=get("/people/#{url_encode(user_id.to_s)}/notes?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
          if resp.code=="200"
            atom=resp.body
            doc=REXML::Document.new(atom)
            author=REXML::XPath.first(doc,"//feed/author")
            author=Author.new(author.to_s) if author
            notes=[]
            REXML::XPath.each(doc,"//feed/entry") do |entry|
              note=Note.new(entry.to_s)
              note.author=author
              notes<<note
            end
            notes
          else
            nil
          end
        end
        def create_note(title=nil,content=nil,option={:privacy=>"public",:can_reply=>"yes"})
          entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
              <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
              <title>#{title}</title>
              <content>#{content}</content>
              <db:attribute name="privacy">#{option[:privacy]}</db:attribute>
              <db:attribute name="can_reply">#{option[:can_reply]}</db:attribute>
              </entry>
              }
          resp=post("/notes",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
          if resp.code=="201"
            true
          else
            false
          end
        end
      def delete_note(note_id=nil)
        resp=delete("/note/#{url_encode(note_id.to_s)}")
        if resp.code=="200"
          true
        else
          false
        end
      end
      def modify_note(note_id=nil,title=nil,content=nil,option={:privacy=>"public",:can_reply=>"yes"})
        entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
              <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
              <title>#{title}</title>
              <content>#{content}</content>
              <db:attribute name="privacy">#{option[:privacy]}</db:attribute>
              <db:attribute name="can_reply">#{option[:can_reply]}</db:attribute>
              </entry>
              }
        resp=put("/note/#{url_encode(note_id.to_s)}",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
        if resp.code=="200"
          true
        else
          false
        end
      end
      def get_event(event_id=nil)
        resp=get("/event/#{url_encode(event_id.to_s)}")
        if resp.code=="200"
          atom=resp.body
          Event.new(atom)
        else
          nil
        end
      end
      def get_participant_people(event_id=nil,option={:start_index=>1,:max_results=>10})
        resp=get("/event/#{url_encode(event_id.to_s)}/participants?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          people=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            people<<People.new(entry.to_s)
          end
          people
        else
          nil
        end
      end
      def get_wisher_people(event_id=nil,option={:start_index=>1,:max_results=>10})
        resp=get("/event/#{url_encode(event_id.to_s)}/wishers?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          people=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            people<<People.new(entry.to_s)
          end
          people
        else
          nil
        end
      end
      def get_user_events(user_id="@me",option={:start_index=>1,:max_results=>10})
        resp=get("/people/#{url_encode(user_id.to_s)}/events?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def get_user_initiate_events(user_id="@me",option={:start_index=>1,:max_results=>10})
        resp=get("/people/#{url_encode(user_id.to_s)}/events/initiate?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def get_user_participate_events(user_id="@me",option={:start_index=>1,:max_results=>10})
        resp=get("/people/#{url_encode(user_id.to_s)}/events/participate?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def get_user_wish_events(user_id="@me",option={:start_index=>1,:max_results=>10})
        resp=get("/people/#{url_encode(user_id.to_s)}/events/wish?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def get_city_events(location_id=nil,option={:type=>"all",:start_index=>1,:max_results=>10})
        resp=get("/event/location/#{url_encode(location_id.to_s)}?type=#{option[:type]}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def search_events(q=nil,option={:location=>"all",:start_index=>1,:max_results=>10})
        resp=get("/events?q=#{url_encode(gbk_to_utf8(q).to_s)}&location=#{option[:location]}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
        if resp.code=="200"
          events=[]
          atom=resp.body
          doc=REXML::Document.new(atom)
          REXML::XPath.each(doc,"//feed/entry") do |entry|
            events<<Event.new(entry.to_s)
          end
          events
        else
          nil
        end
      end
      def create_event(title=nil,content=nil,where=nil,option={:kind=>"exhibit",:invite_only=>"no",:can_invite=>"yes",:when=>{"endTime"=>(Time.now+60*60*24*5).strftime("%Y-%m-%dT%H:%M:%S+08:00"),"startTime"=>Time.now.strftime("%Y-%m-%dT%H:%M:%S+08:00")}})
        entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <title>#{title}</title>
        <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#event.#{option[:kind]}"/>
        <content>#{content}</content>
        <db:attribute name="invite_only">#{option[:invite_only]}</db:attribute>
        <db:attribute name="can_invite">#{option[:can_invite]}</db:attribute>
        <gd:when endTime="#{option[:when]["endTime"]}" startTime="#{option[:when]["startTime"]}"/>
        <gd:where valueString="#{where}" />
        </entry>
        }
        resp=post("/events",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
        if resp.code=="201"
          true
        else
          false
        end
      end
=begin
      def participate_event(event_id=nil)
        resp=post("/event/#{url_encode(event_id.to_s)}/participants","")
        if resp.code=="201"
          true
        else
          false
        end
      end
      def wish_event(event_id=nil)
        resp=post("/event/#{url_encode(event_id)}/wishers")
        if resp.code=="201"
          true
        else
          false
        end
      end
      def delete_participant(event_id=nil)
        resp=delete("/event/#{url_encode(event_id)}/participants")
        if resp.code=="200"
          true
        else
          false
        end
      end
      def delete_wisher(event_id=nil)
        resp=delete("/event/#{url_encode(event_id)}/wishers")
        if resp.code=="200"
          true
        else
          false
        end
      end
=end
      def modify_event(event_id=nil,title=nil,content=nil,where=nil,option={:kind=>"exhibit",:invite_only=>"no",:can_invite=>"yes",:when=>{"endTime"=>(Time.now+60*60*24*5).strftime("%Y-%m-%dT%H:%M:%S+08:00"),"startTime"=>Time.now.strftime("%Y-%m-%dT%H:%M:%S+08:00")}})
        entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <title>#{title}</title>
        <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#event.#{option[:kind]}"/>
        <content>#{content}</content>
        <db:attribute name="invite_only">#{option[:invite_only]}</db:attribute>
        <db:attribute name="can_invite">#{option[:can_invite]}</db:attribute>
        <gd:when endTime="#{option[:when]["endTime"]}" startTime="#{option[:when]["startTime"]}"/>
        <gd:where valueString="#{where}" />
        </entry>
        }
        resp=post("/event/#{url_encode(event_id)}",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
        if resp.code=="200"
          true
        else
          false
        end
      end
=begin
      def delete_event(event_id=nil)
        entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
          <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
          <content>对不起大家，活动因故取消了</content>
          </entry>
            }
            resp=post("/event/#{url_encode(event_id)}/delete",gbk_to_utf8(entry),{"Content-Type"=>"application/atom+xml"})
            if resp.code=="200"
              true
            else
              false
            end
          end
=end
          
end
end
