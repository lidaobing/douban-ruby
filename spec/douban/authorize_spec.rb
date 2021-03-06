# -*- encoding: UTF-8 -*-
require "spec_helper"

require 'douban/authorize'

module Douban
  describe Authorize do
    before(:each) do
      Authorize.debug = true
      @api_key = ENV['DOUBAN_API_KEY'] || '042bc009d7d4a04d0c83401d877de0e7'
      @secret_key = ENV['DOUBAN_SECRET_KEY'] || 'a9bb2d7f8cc00110'
      @authorize = Authorize.new(@api_key, @secret_key)
    end

    context "#request_token" do
      it "should works" do
        @authorize.get_authorize_url
        @authorize.request_token.should be_a(OAuth::RequestToken)
      end

      it "should return OAuth::Token with :as_token param" do
        @authorize.get_authorize_url
        @authorize.request_token(:as_token).should be_a(OAuth::Token)
      end

      it "should return Hash with :as_hash param" do
        @authorize.get_authorize_url
        res = @authorize.request_token(:as_hash)
        res.should be_a(Hash)
        res[:token].should be_a(String)
        res[:secret].should be_a(String)
      end
    end

    context "#request_token=" do
      before :each do
        @request_token = "a" * 32
        @request_secret = "b" * 16
      end

      it "should support OAuth::Token" do
        @authorize.request_token = OAuth::Token.new(@request_token, @request_secret)
        @authorize.request_token.should be_a(OAuth::RequestToken)
      end
      it "should support Hash" do
        @authorize.request_token = {:token => @request_token, :secret => @request_secret}
        @authorize.request_token.should be_a(OAuth::RequestToken)
      end
    end

    context "helper" do
      context "url_encode" do
        it "should support integer" do
          @authorize.send(:url_encode, 1).should == "1"
        end
      end
    end

    context "when oauth login" do
      it "should return login url and request token" do
        @authorize.authorized?.should be_false
        @authorize.get_authorize_url.should =~ %r{^http://.*oauth_token=[0-9a-f]{32}&oauth_callback=.*$}
        @authorize.authorized?.should be_false
        @authorize.request_token.token.should =~ /[0-9a-f]{32}/
        @authorize.request_token.secret.should =~ /[0-9a-f]{16}/
      end
    end

    context "oauth verify" do
      before(:each) do
        @request_token = "a" * 32
        @request_secret = "b" * 16

        @access_token = "c"*32
        @access_secret = "d"*16
      end

      it "auth should works" do
        request_token_mock = mock("request_token")
        request_token_mock.stub!(:kind_of?).with(OAuth::RequestToken).and_return(true)
        request_token_mock.stub!(:get_access_token).and_return(
          OAuth::Token.new(@access_token, @access_secret)
        )

        @authorize.request_token = request_token_mock
        @authorize.auth
        @authorize.access_token.class.should == OAuth::AccessToken
        @authorize.access_token.token.should == @access_token
        @authorize.access_token.secret.should == @access_secret
      end
    end

  context "logged in with oauth" do
    before(:each) do
      Authorize.debug = true
      @access_token = ENV['DOUBAN_ACCESS_TOKEN'] || 'be84e4bc8d0581d03b8eae35a7108570'
      @access_secret = ENV['DOUBAN_ACCESS_SECRET'] || '16eeaa7b1053323c'
      @uid = ENV['DOUBAN_UID'] || '43100799'
      @authorize.access_token = OAuth::Token.new(@access_token, @access_secret)
    end


    it "should authorized?" do
      @authorize.authorized?.should == true
    end

    context "people" do
      context "get_people" do
        it "should works" do
          people = @authorize.get_people
          people.nil?.should == false
          people.uid.should == @uid
        end
      end

      context "get_friends" do
        it "should works" do
          friends = @authorize.get_friends
          friends.size.should >= 2
          friends[0].id.should_not == friends[-1].id
        end
      end

      context "get_contacts" do
        it "should works" do
          friends = @authorize.get_contacts
          friends.size.should >= 2
          friends[0].id.should_not == friends[-1].id
        end
      end

      context "search_people" do
        it "should works" do
          friends = @authorize.search_people('li')
          friends.size.should >= 2
          friends[0].id.should_not == friends[-1].id
        end
      end
    end

    context "miniblog" do
      context "create_miniblog" do
        it "should publish miniblog with html characters and return Miniblog" do
          miniblog = @authorize.create_miniblog("<b>单元测试#{rand}")
          miniblog.kind_of?(Douban::Miniblog).should == true
        end

        it "delete miniblog should works" do
          miniblog = @authorize.create_miniblog("<b>单元测试#{rand}")
          miniblog.kind_of?(Douban::Miniblog).should == true
          id = %r{http://api.douban.com/miniblog/(\d+)}.match(miniblog.id)[1]
          @authorize.delete_miniblog(id).should == true
        end
      end

      context "get_user_miniblog" do
        it "should return [Miniblog] with different id" do
          miniblogs = @authorize.get_user_miniblog
          miniblogs.size.should >= 2
          miniblogs[0].class.should == Miniblog
          miniblogs[0].id.should_not == miniblogs[-1].id
        end
      end

      context "get_user_contact_miniblog" do
        it "should return [Miniblog] with different id" do
          miniblogs = @authorize.get_user_contact_miniblog
          miniblogs.size.should >= 2
          miniblogs[0].class.should == Miniblog
          miniblogs[0].id.should_not == miniblogs[-1].id
        end
      end

      context "get_miniblog_comments" do
        it "should return [MiniblogComment] with different id" do
          comments = @authorize.get_miniblog_comments(378744647)
          comments.comments.size.should >= 2
          comments.comments[0].id.should_not == comments.comments[-1].id
        end

        it "should support start_index" do
          comments1 = @authorize.get_miniblog_comments(378744647)
          comments2 = @authorize.get_miniblog_comments(378744647, :start_index => 2)
          comments1.comments[1].id.should == comments2.comments[0].id
        end

        it "should support max_results" do
          @authorize.get_miniblog_comments(378744647, :max_results=>1).comments.size.should == 1
        end
      end
      context "create_miniblog_comment" do
        it "should works" do
=begin
HTTP/1.1 201 Created
Content-Type: text/xml; charset=utf-8
Content-Length: 701

<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/miniblog/378744647/comment/122711444</id>
        <author>
                <link href="http://api.douban.com/people/43100799" rel="self"/>
                <link href="http://www.douban.com/people/43100799/" rel="alternate"/>
                <name>douban-ruby</name>
                <uri>http://api.douban.com/people/43100799</uri>
        </author>
        <published>2012-03-27T12:58:45+08:00</published>
        <content>单元测试0.6508066526913802</content>
</entry>
=end
          comment = @authorize.create_miniblog_comment(378744647, "单元测试#{rand}")
          comment.class.should == MiniblogComment
          @authorize.delete_miniblog_comment(comment).should == true
        end
      end
    end

    context "recommendation" do
      before do
        @recommendation_id = 4312524
        @recommendation_title = "推荐活动QClub：敏捷在互联网时代产品研发中的实践（12.27 深圳）"
      end


      context "get_recommendation" do
        it "should return Recommendation if found" do
          recommendation = @authorize.get_recommendation(@recommendation_id)
          recommendation.class.should == Douban::Recommendation
          recommendation.title.should == @recommendation_title
        end

        it "should return nil if not found" do
          @authorize.get_recommendation(28732532).should == nil
        end
      end
      context "get_user_recommendations" do
        it "should work" do
          recommendations = @authorize.get_user_recommendations("aka")
          recommendations.size.should >= 2
          recommendations[0].class.should == Douban::Recommendation
          recommendations[0].id.should_not == recommendations[-1].id
        end
      end
      context "get_recommendation_comments" do
        it "should work" do
          recommendations = @authorize.get_recommendation_comments(4312524)
          recommendations.size.should >= 2
          recommendations[0].class.should == Douban::RecommendationComment
          recommendations[0].id.should_not == recommendations[-1].id
        end
      end
      context "create_recommendation & delete_recommendation" do
        it "should return a Recommendation and can be delete" do
          recommendation = @authorize.create_recommendation("http://api.douban.com/movie/subject/1424406", "标题", "神作")
          recommendation.class.should == Douban::Recommendation
          recommendation.comment.should == "神作"
          @authorize.delete_recommendation(recommendation).should == true
        end
        it "should can delete through recommendation_id" do
          @authorize.delete_recommendation(
              @authorize.create_recommendation("http://api.douban.com/movie/subject/1424406", "标题", "神作").recommendation_id).should == true
        end
      end

      context "create_recommendation_comment & delete_recommendation_comment" do
        it "should return a RecommendationComment and can be delete" do
          comment = @authorize.create_recommendation_comment(@recommendation_id, "好文")
          comment.class.should == Douban::RecommendationComment
          comment.content.should == "好文"
          @authorize.delete_recommendation_comment(comment).should == true
        end
        it "should can be delete through recommendation and comment_id" do
          comment = @authorize.create_recommendation_comment(@recommendation_id, "好文")
          @authorize.delete_recommendation_comment(@authorize.get_recommendation(@recommendation_id),
            comment.comment_id).should == true
        end
          it "should can be delete through recommendation_id and comment_id" do
            comment = @authorize.create_recommendation_comment(@recommendation_id, "好文")
            @authorize.delete_recommendation_comment(@recommendation_id, comment.comment_id).should == true
          end
        end
      end

      context "collection" do
        context "create_collection" do
          it "should return Collection" do
            collection = @authorize.create_collection("http://api.douban.com/movie/subject/1424406", "a", 5, "watched", ["tag"])
            collection.class.should == Douban::Collection
            @authorize.delete_collection(collection).should == true
          end
        end

        context "modify_collection" do
          it "should return Collection" do
            collection = @authorize.create_collection("http://api.douban.com/movie/subject/1424406", "a", 5, "watched", ["tag"])
            collection = @authorize.modify_collection(collection, nil, "b", 5, "watched", ["tag"])
            collection.class.should == Douban::Collection
            collection.summary.should == "b"
            @authorize.delete_collection(collection).should == true
          end
        end

        context "get_user_collection" do
          it "should return [Collection] with different id" do
            collections = @authorize.get_user_collection
            collections.size.should >= 2
            collections[0].class.should == Collection
            collections[0].id.should_not == collections[-1].id
          end
        end
      end

      context "event" do
        #context "create_event" do
        #  it "should return Event" do
        #    event = @authorize.create_event("douban-ruby 单元测试", "event 好像不能自动删除", "大山子798艺术区 IT馆")
        #    event.class.should == Douban::Event
        #  end
        #end

        context "get_event_participant_people" do
          it "should return [People] with different id" do
            event_id = 11723349
            people = @authorize.get_event_participant_people(event_id)
            people.size.should >= 2
            people[0].class.should == People
            people[0].id.should_not == people[-1].id
          end
        end

        context "get_wisher_people" do
          it "should return [People] with different id" do
            event_id = 11723349
            people = @authorize.get_event_wisher_people(event_id)
            people.size.should >= 2
            people[0].class.should == People
            people[0].id.should_not == people[-1].id
          end
        end

        context "get_user_events" do
          it "should return [Event] with different id" do
            people_id = 'supernb'
            events = @authorize.get_user_events(people_id)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

        context "get_user_initiate_events" do
          it "should return [Event] with different id" do
            people_id = 'supernb'
            events = @authorize.get_user_initiate_events(people_id)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

        context "get_user_participate_events" do
          it "should return [Event] with different id" do
            people_id = 'supernb'
            events = @authorize.get_user_participate_events(people_id)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

        context "get_user_wish_events" do
          it "should return [Event] with different id" do
            people_id = 'supernb'
            events = @authorize.get_user_wish_events(people_id)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

        context "get_city_events" do
          it "should return [Event] with different id" do
            city_id = 'beijing'
            events = @authorize.get_city_events(city_id)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

        context "search_events" do
          it "should return [Event] with different id" do
            q = '电影'
            events = @authorize.search_events(q)
            events.size.should >= 2
            events[0].class.should == Event
            events[0].id.should_not == events[-1].id
          end
        end

=begin
        context "modify_event" do
          it "should return Event" do
            event = @authorize.create_event("douban-ruby 单元测试", "event 好像不能自动删除", "大山子798艺术区 IT馆")
            event = @authorize.modify_event(event, "douban-ruby 单元测试", "event 好像不能自动删除", "大山子798艺术区 IT馆")
            event.class.should == Douban::Event
            event.title.should == "douban-ruby 单元测试2"
          end
        end
=end
      end

      context "mail" do
        context "get_mail_inbox" do
          it "should works" do
            @mails = @authorize.get_mail_inbox
            @mails.size.should >= 2
            @mails[0].id.should_not == @mails[-1].id
          end
        end

        context "send_mail" do
          it "should success or return captcha_token" do
            res = @authorize.send_mail("lidaobing", "hello", "world")
            if res.class != Hash
              res.should == true
            end
          end
        end

        context "get_mail" do
          it "should work" do
            mail = @authorize.get_mail(82937520)
            mail.class.should == Mail
          end
        end

        context "get_unread_mail" do
          it "should return [Mail] with different id" do
            mails = @authorize.get_unread_mail
            mails.size.should >= 2
            mails[0].class.should == Mail
            mails[0].id.should_not == mails[-1].id
          end
        end

        context "get_mail_outbox" do
          it "should return [Mail] with different id" do
            mails = @authorize.get_mail_outbox
            mails.size.should >= 2
            mails[0].class.should == Mail
            mails[0].id.should_not == mails[-1].id
          end
        end
      end

      context "note" do
        context "create_note" do
          it "should return Note" do
            note = @authorize.create_note("a", "b")
            note.class.should == Note
            @authorize.delete_note(note).should == true
          end
        end

        context "modify_note" do
          it "should return Note" do
            note = @authorize.create_note("a", "b")
            note = @authorize.modify_note(note, "c", "d")
            note.class.should == Note
            note.title.should == "c"
            @authorize.delete_note(note).should == true
          end
        end

        context "get_user_notes" do
          it "should return notes with different id" do
            notes = @authorize.get_user_notes
            notes.size.should >= 2
            notes[0].id.should_not == notes[-1].id
          end
        end
      end

      context "review" do

        context "create review" do
          it "should return Review" do
            @subject = @authorize.get_book(1088840)
            review = @authorize.create_review(@subject, "douban-ruby 单元测试",
              "douban-ruby 单元测试"*10)
            review.class.should == Review
            @authorize.delete_review(review).should == true
          end
        end

        context "modify review" do
          it "should return Review" do
            @subject = @authorize.get_book(1088840)
            review = @authorize.create_review(@subject, "douban-ruby 单元测试",
              "douban-ruby 单元测试"*10)
            review = @authorize.modify_review(review, nil, "douban-ruby 单元测试", "douban-ruby 单元测试"*11)
            review.class.should == Review
            review.content.should == "douban-ruby 单元测试"*11
            @authorize.delete_review(review).should == true
          end
        end

        context "get_book_reviews" do
          it "should return [Review] with different id" do
            reviews = @authorize.get_book_reviews(1258490)
            reviews.size.should >= 2
            reviews[0].id.should_not == reviews[-1].id
          end
        end

        context "get_user_reviews" do
          it "should return [Review] with different id" do
            reviews = @authorize.get_user_reviews('40896712')
            reviews.size.should >= 2
            reviews[0].id.should_not == reviews[-1].id
          end
        end
      end

      context "subject" do

        context "get_book" do
          it "should return Book" do
            book = @authorize.get_book(1088840)
            book.class.should == Book
          end

          it "should support :id => id" do
            @authorize.get_book(:id => 1088840).should == @authorize.get_book(1088840)
          end

          it "should support :isbn => isbn" do
            @authorize.get_book(:isbn => 9787040048803).should == @authorize.get_book(1088840)
          end

          it "should support Book" do
            book = @authorize.get_book(1088840)
            @authorize.get_book(book).should == book
          end
        end

        context "get_movie" do
          it "should return Movie" do
            movie = @authorize.get_movie(1858711)
            movie.class.should == Movie
          end

          it "should support :id => id" do
            @authorize.get_movie(:id => 1858711).should == @authorize.get_movie(1858711)
          end

          it "should support :imdb => imdb" do
            @authorize.get_movie(:imdb => 'tt0435761').should == @authorize.get_movie(1858711)
          end

          it "should support Movie" do
            movie = @authorize.get_movie(1858711)
            @authorize.get_movie(movie).should == movie
          end
        end

        context "search_book" do
          it "should support query" do
            books = @authorize.search_book("ruby")
            books.size.should >= 2
            books[0].class.should == Book
            books[0].id.should_not == books[-1].id
          end

          it "should support :q => query" do
            books = @authorize.search_book(:q => "ruby")
            books.size.should >= 2
            books[0].class.should == Book
            books[0].id.should_not == books[-1].id
          end

          it "should support :tag => tag" do
            books = @authorize.search_book(:tag => "ruby")
            books.size.should >= 2
            books[0].class.should == Book
            books[0].id.should_not == books[-1].id
          end
        end
        context "search_movie" do
          it "should return [Movie] with different id" do
            movies = @authorize.search_movie("america")
            movies.size.should >= 2
            movies[0].class.should == Movie
            movies[0].id.should_not == movies[-1].id
          end
        end
        context "search_music" do
          it "should return [Music] with different id" do
            musics = @authorize.search_music("america")
            musics.size.should >= 2
            musics[0].class.should == Music
            musics[0].id.should_not == musics[-1].id
          end
        end

        context "get_book_tags" do
          it "should return [Tag] with different id" do
            book_id = 4741216
            tags = @authorize.get_book_tags(book_id)
            tags.size.should >= 2
            tags[0].class.should == Tag
            tags[0].id.should_not == tags[-1].id
          end
        end

        context "get_user_tags" do
          it "should return [Tag] with different id" do
            tags = @authorize.get_user_tags()
            tags.size.should >= 2
            tags[0].class.should == Tag
            tags[0].id.should_not == tags[-1].id
          end
        end
      end

      context "verify_token" do
        it "should return true" do
          @authorize.verify_token.should == true
        end
      end
    end # context "logged in with oauth"
  end #describe
end #Module

