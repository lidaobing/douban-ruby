require 'rubygems'
gem 'oauth'
require 'oauth'
require 'oauth/consumer'
require 'rexml/document'
require 'net/http'
require 'douban'

module Douban
  class Authorize
    include Douban
    attr_reader :api_key
    attr_reader :api_secret
    attr_reader :authorize_url
    attr_reader :consumer
    attr_reader :request_token
    attr_reader :access_token

    @@debug = false

    def self.debug=(val)
      @@debug = val
    end

    def initialize(api_key, secret_key, options={})
      @api_key=api_key
      @secret_key=secret_key
      default_options = {
        :signature_method=>"HMAC-SHA1",
        :site=>OAUTH_HOST,
        :request_token_path=>REQUEST_TOKEN_PATH,
        :access_token_path=>ACCESS_TOKEN_PATH,
        :authorize_path=>AUTHORIZE_PATH ,
        :scheme=>:header,
        :realm=>"http://www.example.com/"
      }
      @oauth_option=default_options.merge(options)
      yield self if block_given?
      self
    end

    def authorized?
      ! @access_token.nil?
    end

    def get_authorize_url(oauth_callback=nil)
      oauth_callback ||= @oauth_option[:realm]

      @consumer=OAuth::Consumer.new(@api_key,@secret_key,@oauth_option)
      @request_token=@consumer.get_request_token
      @authorize_url="#{@request_token.authorize_url}&oauth_callback=#{CGI.escape(oauth_callback)}"
      yield @request_token if block_given?
      @authorize_url
    end

    def auth
      begin
        @access_token=@request_token.get_access_token
        @access_token=OAuth::AccessToken.new(
          OAuth::Consumer.new(
            @api_key,
            @secret_key,
            {
          :site=>API_HOST,
          :scheme=>:header,
          :signature_method=>"HMAC-SHA1",
          :realm=>@oauth_option[:realm]
        }
        ),
          @access_token.token,
          @access_token.secret
        )
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
          friends << People.new(entry)
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
          contacts << People.new(entry)
        end
        contacts
      else
        nil
      end
    end


    def search_people(q="",option={:start_index=>1,:max_results=>10})
      resp=get("/people?q=#{url_encode(q.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        results=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          results << People.new(entry)
        end
        results
      else
        nil
      end
    end
    def get_book(id="")
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
    def get_movie(id="")
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
    def search_book(tag="",option={:start_index=>1,:max_results=>10})
      resp=get("/book/subjects?tag=#{url_encode(tag.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        atom=resp.body
        doc=REXML::Document.new(atom)
        books=[]
        REXML::XPath.each(doc,"//entry") do |entry|
          books << Book.new(entry)
        end
        books
      else
        nil
      end

    end
    def search_movie(tag="",option={:start_index=>1,:max_results=>10})
      resp=get("/movie/subjects?tag=#{url_encode(tag.to_s)}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        atom=resp.body
        doc=REXML::Document.new(atom)
        movies=[]
        REXML::XPath.each(doc,"//entry") do |entry|
          movies << Movie.new(entry)
        end
        movies
      else
        nil
      end
    end
    def search_music(tag="",option={:start_index=>1,:max_results=>10})
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
    def get_review(id="")
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
          reviews<< Review.new(entry)
        end
        reviews
      else
        debug(resp)
      end
    end
    def get_movie_reviews(subject_id="",option={:start_index=>1,:max_results=>10,:orderby=>'score'})
      resp=get("/movie/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
      if resp.code=="200"
        atom=resp.body
        reviews=[]
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|

          reviews<< Review.new(entry)
        end
        reviews
      else
        nil
      end
    end
    def get_music_reviews(subject_id="",option={:start_index=>1,:max_results=>10,:orderby=>'score'})
      resp=get("/music/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
      if resp.code=="200"
        atom=resp.body
        reviews=[]
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          reviews<< Review.new(entry)
        end
        reviews
      else
        nil
      end
    end
    def get_book_reviews(subject_id="",option={:start_index=>1,:max_results=>10,:orderby=>'score'})
      resp=get("/book/subject/#{url_encode(subject_id.to_s)}/reviews?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}&orderby=#{option[:orderby]}")
      if resp.code=="200"
        atom=resp.body
        reviews=[]
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          reviews<< Review.new(entry)
        end
        reviews
      else
        nil
      end
    end

    def delete_review(review)
      review_id = case review
        when Review then review.review_id
        else review
      end

      resp=delete("/review/#{url_encode(review_id.to_s)}")
      if resp.code=="200"
        true
      else
        false
      end
    end

    def create_review(subject_link="",title="",content="",rating=5)
      subject_link = subject_link.id if subject_link.kind_of?(Subject)

      entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
              <entry xmlns:ns0="http://www.w3.org/2005/Atom">
              <db:subject xmlns:db="http://www.douban.com/xmlns/">
              <id>#{h subject_link}</id>
              </db:subject>
              <content>#{h content}</content>
              <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{h rating}" ></gd:rating>
              <title>#{h title}</title>
              </entry>
      }
      resp=post("/reviews",entry,{"Content-Type" => "application/atom+xml"})
      if resp.code=="201"
        Review.new(resp.body)
      else
        debug(resp)
      end
    end

    def modify_review(review, subject_link=nil,title="",content="",rating=5)
      review_id = case review
      when Review then review.review_id
      else review
      end

      subject_link = review.subject.id if subject_link.nil? and review.kind_of?(Review)

      entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
                  <entry xmlns:ns0="http://www.w3.org/2005/Atom">
                  <id>http://api.douban.com/review/#{h review_id}</id>
                  <db:subject xmlns:db="http://www.douban.com/xmlns/">
                  <id>#{h subject_link}</id>
                  </db:subject>
                  <content>#{h content}</content>
                  <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{h rating}" ></gd:rating>
                  <title>#{h title}</title>
                  </entry>
      }
      resp=put("/review/#{url_encode(review_id)}",entry,{"Content-Type" => "application/atom+xml"})
      if resp.code=="202"
        Review.new(resp.body)
      else
        debug(resp)
      end
    end
    def get_collection(collection_id="")
      resp=get("/collection/#{url_encode(collection_id.to_s)}")
      if resp.code=="200"
        atom=resp.body
        Collection.new(atom)
      else
        nil
      end
    end
    def get_user_collection(
      user_id="@me",
      option={
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
        collections<< collection
      end
      collections
    else
      nil
    end
    end
    def create_collection( subject_id="",content="",rating=5,status="",tag=[],option={ :privacy=>"public"})
      db_tag=""
      if tag.size==0
        db_tag='<db:tag name="" />'
      else
        tag.each do |t|
          db_tag+=%Q{<db:tag name="#{h t}" />}
        end
      end
      entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
              <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
              <db:status>#{h status}</db:status>
        #{db_tag}
              <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{h rating}" />
              <content>#{h content}</content>
              <db:subject>
              <id>#{h subject_id}</id>
              </db:subject>
              <db:attribute name="privacy">#{h option[:privacy]}</db:attribute>
              </entry>
      }
      resp=post("/collection",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="201"
        Collection.new(resp.body)
      else
        debug(resp)
      end
    end

    def modify_collection(collection, subject_id="",content="",rating=5,status="",tag=[],option={:privacy=>"public"})
      collection_id = case collection
        when Collection then collection.collection_id
        else collection
      end

      subject_id = collection.subject.id if subject_id.nil? and collection.kind_of?(Collection)

      db_tag=""
      if tag.size==0
        db_tag='<db:tag name="" />'
      else
        tag.each do |t|
          db_tag+=%Q{<db:tag name="#{h t}" />}
        end
      end
      entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
              <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
              <id>http://api.douban.com/collection/#{h collection_id}</id>
              <db:status>#{h status}</db:status>

        #{db_tag}
              <gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="#{h rating}" />
              <content>#{h content}</content>
              <db:subject>
              <id>#{h subject_id}</id>
              </db:subject>
              <db:attribute name="privacy">#{h option[:privacy]}</db:attribute>
              </entry>
      }
      resp=put("/collection/#{u collection_id}",entry,{"Content-Type"=>"application/atom+xml"})
      # resp.code should be 202, but currently it's 200
      # http://www.douban.com/group/topic/12451628/
      if resp.code=="200" or resp.code == "202"
        Collection.new(resp.body)
      else
        debug(resp)
      end
    end
    def delete_collection(collection)
      collection_id = case collection
      when Collection then collection.collection_id
      else collection
      end

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
          miniblogs<< miniblog
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
          miniblogs<< miniblog
        end
        miniblogs
      else
        nil
      end
    end
    def create_miniblog(content="")
      entry=%Q{<?xml version='1.0' encoding='UTF-8'?>
        <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
        <content>#{h content}</content>
        </entry>}
      resp=post("/miniblog/saying",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="201"
        Miniblog.new(resp.body)
      else
        nil
      end
    end
    def delete_miniblog(miniblog_id="")
      resp=delete("/miniblog/#{url_encode(miniblog_id.to_s)}")
      if resp.code=="200"
        true
      else
        false
      end
    end
    def get_note(note_id="")
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
          note=Note.new(entry)
          note.author=author
          notes << note
        end
        notes
      else
        nil
      end
    end

    def create_note(title="",content="",option={:privacy=>"public",:can_reply=>"yes"})
      entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
                  <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
                  <title>#{h title}</title>
                  <content>#{h content}</content>
                  <db:attribute name="privacy">#{h option[:privacy]}</db:attribute>
                  <db:attribute name="can_reply">#{h option[:can_reply]}</db:attribute>
                  </entry>
      }
      resp=post("/notes",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="201"
        Note.new(resp.body)
      else
        debug(resp)
      end
    end

    def delete_note(note_id="")
      note_id = note_id.note_id if note_id.kind_of?(Note)

      resp=delete("/note/#{url_encode(note_id.to_s)}")
      if resp.code=="200"
        true
      else
        false
      end
    end

    def modify_note(note,title="",content="",option={:privacy=>"public",:can_reply=>"yes"})
      note_id = case note
        when Note then note.note_id
        else note
      end

      entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
                  <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
                  <title>#{h title}</title>
                  <content>#{h content}</content>
                  <db:attribute name="privacy">#{h option[:privacy]}</db:attribute>
                  <db:attribute name="can_reply">#{h option[:can_reply]}</db:attribute>
                  </entry>
      }
      resp=put("/note/#{url_encode(note_id.to_s)}",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="202"
        Note.new(resp.body)
      else
        debug(resp)
      end
    end
    def get_event(event_id="")
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
          people<< People.new(entry.to_s)
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
          people<< People.new(entry.to_s)
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
          events<< Event.new(entry.to_s)
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
          events<< Event.new(entry.to_s)
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
          events<< Event.new(entry.to_s)
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
          events<< Event.new(entry.to_s)
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
          events<< Event.new(entry.to_s)
        end
        events
      else
        nil
      end
    end
    def search_events(q="",option={:location=>"all",:start_index=>1,:max_results=>10})
      resp=get("/events?q=#{url_encode(q.to_s)}&location=#{option[:location]}&start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        events=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//feed/entry") do |entry|
          events<< Event.new(entry.to_s)
        end
        events
      else
        nil
      end
    end
    def create_event(title="",content="",where="",option={:kind=>"party",:invite_only=>"no",:can_invite=>"yes",:when=>{"endTime"=>(Time.now+60*60*24*5).strftime("%Y-%m-%dT%H:%M:%S+08:00"),"startTime"=>Time.now.strftime("%Y-%m-%dT%H:%M:%S+08:00")}})
      entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
            <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
            <title>#{h title}</title>
            <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#event.#{option[:kind]}"/>
            <content>#{h content}</content>
            <db:attribute name="invite_only">#{h option[:invite_only]}</db:attribute>
            <db:attribute name="can_invite">#{h option[:can_invite]}</db:attribute>
            <gd:when endTime="#{h option[:when]["endTime"]}" startTime="#{h option[:when]["startTime"]}"/>
            <gd:where valueString="#{h where}" />
            </entry>
      }
      resp=post("/events",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="201"
        Event.new(resp.body)
      else
        debug(resp)
      end
    end

    def modify_event(event,title=nil,content=nil,where=nil,option=nil)

      event_id = case event
        when Event then event.event_id
        else event
      end

      option = {} if option.nil?
      option = {:kind=>"exhibit",
        :invite_only=>"no",
        :can_invite=>"yes",
        :when=>{"endTime"=>(Time.now+60*60*24*5).strftime("%Y-%m-%dT%H:%M:%S+08:00"),
          "startTime"=>Time.now.strftime("%Y-%m-%dT%H:%M:%S+08:00")}}.merge(option)

      entry=%Q{<?xml version="1.0" encoding="UTF-8"?>
            <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
            <title>#{h title}</title>
            <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#event.#{option[:kind]}"/>
            <content>#{h content}</content>
            <db:attribute name="invite_only">#{h option[:invite_only]}</db:attribute>
            <db:attribute name="can_invite">#{h option[:can_invite]}</db:attribute>
            <gd:when endTime="#{h option[:when]["endTime"]}" startTime="#{h option[:when]["startTime"]}"/>
            <gd:where valueString="#{h where}" />
            </entry>
      }
      resp=put("/event/#{url_encode(event_id)}",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="200"
        Event.new(resp.body)
      else
        debug(resp)
      end
    end

    def get_mail_inbox(option={:start_index=>1,:max_results=>10})
      resp=get("/doumail/inbox?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        mails=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          mails << Mail.new(entry)
        end
        mails
      else
        nil
      end
    end
    def get_unread_mail(option={:start_index=>1,:max_results=>10})
      resp=get("/doumail/inbox/unread?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        mails=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          mails << Mail.new(entry.to_s)
        end
        mails
      else
        nil
      end
    end
    def get_mail_outbox(option={:start_index=>1,:max_results=>10})
      resp=get("/doumail/outbox?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code=="200"
        mails=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          mails << Mail.new(entry.to_s)
        end
        mails
      else
        nil
      end
    end
    def get_mail(mail_id="",keep_unread="false")
      resp=get("/doumail/#{url_encode(mail_id.to_s)}?keep-unread=#{keep_unread}")
      if resp.code=="200"
        atom=resp.body
        Mail.new(atom)
      else
        nil
      end
    end

    # <b>DEPRECATED:</b> Please use <tt>send_mail</tt> instead.
    def create_mail(*args)
      warn "[DEPRECATION] `create_mail` is deprecated.  Please use `send_mail` instead."
      send_mail(*args)
    end

    def send_mail(id="",title="",content="",captcha_token="",captcha_string="")
      if !(captcha_token.empty?&&captcha_string.empty?)
        entry=%Q(<?xml version="1.0" encoding="UTF-8"?>
                 <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
                 <db:entity name="receiver"><uri>http://api.douban.com/people/#{h id}</uri></db:entity>
                 <content>#{h content}</content>
                 <title>#{h title}</title>
                 <db:attribute name="captcha_token">#{h captcha_token}</db:attribute>
                 <db:attribute name="captcha_string">#{h captcha_string}</db:attribute>
                 </entry>)
      else
        entry=%Q(<?xml version="1.0" encoding="UTF-8"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
                 <db:entity name="receiver">
                 <uri>http://api.douban.com/people/#{h id}</uri></db:entity>
                 <content>#{h content}</content>
                 <title>#{h title}</title>
        </entry>)
      end
      resp=post("/doumails",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="201"
        true
      elsif resp.code=="403"
        hash={}
        str=decode(resp.body)
        hash[:token]=str.scan(/^captcha_token=(.*?)&/).flatten.to_s
        hash[:url]=str.scan(/captcha_url=(.*?)$/).flatten.to_s
        hash
      else
        debug(resp)
      end
    end
    def read_mail(mail_id="")
      entry=%Q{<?xml version="1.0" encoding="UTF-8"?><entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/"><db:attribute name="unread">false</db:attribute></entry>}
      resp=put("/doumail/#{mail_id.to_s}",entry,{"Content-Type" => "application/atom+xml"})
      if resp.code=="202"
        true
      else
        false
      end
    end
    def delete_mail(mail_id="")
      resp=delete("/doumail/#{mail_id.to_s}")
      if resp.code=="200"
        true
      else
        false
      end
    end
    def read_mails(mail_ids=[])
      entrys=""
      mail_ids.each do |mail_id|
        entrys +=%Q{<entry><id>http://api.douban.com/doumail/#{mail_id}</id><db:attribute name="unread">false</db:attribute></entry>}
      end
      feed=%Q{<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">#{entrys}</feed>}
      resp=put("/doumail/",feed,{"Content-Type" => "application/atom+xml"})
      if resp.code=="202"
        true
      else
        false
      end
    end
    def delete_mails(mail_ids=[])
      entrys=""
      mail_ids.each do |mail_id|
        entrys += %Q{<entry><id>http://api.douban.com/doumail/#{mail_id}</id></entry>}
      end
      feed=%Q{<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">#{entrys}</feed>}
      resp=post("/doumail/delete",feed,{"Content-Type" => "application/atom+xml"})
      if resp.code=="202"
        true
      else
        false
      end
    end

    def get_book_tags(subject_id="",flag=:book)
      case flag
      when :book
        resp=get("/book/subject/#{subject_id}/tags")
      when :music
        resp=get("/music/subject/#{subject_id}/tags")
      when :movie
        resp=get("/movie/subject/#{subject_id}/tags")
      end
      if resp.code=="200"
        tags=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          tags << Tag.new(entry.to_s)
        end
        tags
      else
        nil
      end
    end
    def get_user_tags(user_id="",flag=:book,option={:max_results=>10})
      case flag
      when :book
        resp=get("/people/#{user_id}/tags?cat=book&max-results=#{option[:max_results]}")
      when :music
        resp=get("/people/#{user_id}/tags?cat=music&max-results=#{option[:max_results]}")
      when :movie
        resp=get("/people/#{user_id}/tags?cat=movie&max-results=#{option[:max_results]}")
      end
      if resp.code=="200"
        tags=[]
        atom=resp.body
        doc=REXML::Document.new(atom)
        REXML::XPath.each(doc,"//entry") do |entry|
          tags << Tag.new(entry.to_s)
        end
        tags
      else
        nil
      end
    end

    def delete_event(event_id="")
      entry=%Q{<?xml version='1.0' encoding='UTF-8'?><entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/"><content>sorry!!!</content></entry>}
      resp=post("/event/#{url_encode(event_id)}/delete",entry,{"Content-Type"=>"application/atom+xml"})
      if resp.code=="200"
        true
      else
        debug(resp, false)
      end
    end

    def request_token=(token)
      unless token.kind_of? OAuth::RequestToken
        token = OAuth::RequestToken.new(
          new_request_consumer,
          token.token,
          token.secret)
      end
      @request_token = token
    end

    def access_token=(token)
      unless token.kind_of? OAuth::AccessToken
        token = OAuth::AccessToken.new(
          new_access_consumer,
          token.token,
          token.secret)
      end
      @access_token = token
    end

    def get_recommendation(id)
      resp=get("/recommendation/#{url_encode(id.to_s)}")
      if resp.code=="200"
        Recommendation.new(resp.body)
      elsif resp.code == "404"
        nil
      else
        debug(resp)
      end
    end

    def get_user_recommendations(user_id="@me",option={:start_index=>1,:max_results=>10})
      resp=get("/people/#{url_encode(user_id.to_s)}/recommendations?start-index=#{option[:start_index]}&max-results=#{option[:max_results]}")
      if resp.code == "200"
        recommendations = []
        doc=REXML::Document.new(resp.body)
        REXML::XPath.each(doc,"//entry") do |entry|
          recommendations << Recommendation.new(entry)
        end
        recommendations
      else
        debug(resp)
      end
    end

    def get_recommendation_comments(recommendation_id)
      resp = get("/recommendation/#{url_encode(recommendation_id)}/comments")
      if resp.code == "200"
        comments = []
        doc=REXML::Document.new(resp.body)
        REXML::XPath.each(doc, "//entry") do |entry|
          comments << RecommendationComment.new(entry)
        end
        comments
      else
        debug(resp)
      end
    end

    def create_recommendation(subject, title, comment)
      subject = subject.kind_of?(Douban::Subject) ? subject.id : subject
      entry = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
        xmlns:gd="http://schemas.google.com/g/2005"
        xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/"
        xmlns:db="http://www.douban.com/xmlns/">
        <title>#{h title}</title>
        <db:attribute name="comment">#{h comment}</db:attribute>
        <link href="#{h subject}" rel="related" />
</entry>}
      resp = post("/recommendations", entry, {"Content-Type"=>"application/atom+xml"})
      if resp.code == '201'
        Recommendation.new(resp.body)
      else
        debug(resp)
      end
    end

    def delete_recommendation(recommendation_id)
      if recommendation_id.kind_of?(Douban::Recommendation)
        recommendation_id = %r{/(\d+)$}.match(recommendation_id.id)[1]
      end

      resp = delete("/recommendation/#{u recommendation_id}")
      if resp.code == '200'
        true
      else
        debug(resp, false)
      end
    end

    def create_recommendation_comment(recommendation, content)
      recommendation_id = recommendation.kind_of?(Douban::Recommendation) \
        ? recommendation.recommendation_id : recommendation
      entry = %Q{<?xml version='1.0' encoding='UTF-8'?>
    <entry>
        <content>#{h content}</content>
    </entry>}
      resp = post("/recommendation/#{u recommendation_id}/comments", entry, {"Content-Type"=>"application/atom+xml"})
      if resp.code == '201'
        RecommendationComment.new(resp.body)
      else
        debug(resp)
      end
    end

    # delete_recommendation_comment(comment:RecommendationComment)
    # delete_recommendation_comment(recommendation:Recommendation, comment_id:Integer)
    # delete_recommendation_comment(recommendation_id:Integer, comment_id:Integer)
    def delete_recommendation_comment(recommendation, comment_id=nil)
      if comment_id.nil?
        recommendation_id = recommendation.recommendation_id
        comment_id = recommendation.comment_id
      else
        recommendation_id = recommendation.kind_of?(Douban::Recommendation) \
          ? recommendation.recommendation_id : recommendation
      end
      resp = delete("/recommendation/#{u recommendation_id}/comment/#{u comment_id}")
      if resp.code == '200'
        true
      else
        debug(resp, false)
      end
    end

    private
    def new_request_consumer
      OAuth::Consumer.new(@api_key, @secret_key, @oauth_option)
    end

    def new_access_consumer
      OAuth::Consumer.new(@api_key, @secret_key,
                          :site=>API_HOST,
                          :scheme=>:header,
                          :signature_method=>"HMAC-SHA1",
                          :realm=>@oauth_option[:realm])
    end

    def debug(resp, retval=nil)
      if @@debug
        p resp.code
        p resp.body
      end
      retval
    end

    def h(o)
      CGI.escapeHTML(o.to_s)
    end

    def u(o)
      CGI.escape(o.to_s)
    end
  end
end

