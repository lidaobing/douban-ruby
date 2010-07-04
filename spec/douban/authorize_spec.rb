
require 'douban/authorize'

module Douban
  describe Authorize do
    before(:each) do
      Authorize.debug = true
      @api_key = '042bc009d7d4a04d0c83401d877de0e7'
      @secret_key = 'a9bb2d7f8cc00110'
      @authorize = Authorize.new(@api_key, @secret_key)
    end

    context "helper" do
      context "url_encode" do
        it "should support integer" do
          @authorize.url_encode(1).should == "1"
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

      it "should support set request token" do
        @authorize.request_token = OAuth::Token.new(@request_token, @request_secret)
        @authorize.request_token.kind_of?(OAuth::RequestToken).should == true
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
      @access_token = '0306646daca492b609132d4905edb822'
      @access_secret = '22070cec426cb925'
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
          people.uid.should == "41502874"
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
        context "create_event" do
          it "should return Event" do
            event = @authorize.create_event("douban-ruby 单元测试", "event 好像不能自动删除", "大山子798艺术区 IT馆")
            event.class.should == Douban::Event
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
            mail = @authorize.send_mail("lidaobing", "hello", "world")
            if mail.class != Hash
              mail.class.should == true
            end
          end
        end

        context "get_mail" do
          it "should work" do
            mail = @authorize.get_mail(82937520)
            mail.class.should == Mail
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
        context "search_book" do
          it "should return [Book] with different id" do
            books = @authorize.search_book("ruby")
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
      end


    end # context "logged in with oauth"
  end #describe
end #Module

