require File.join(File.dirname(__FILE__), '/../spec_helper')

module Douban
  describe Authorize do
    before(:each) do
      @api_key = '042bc009d7d4a04d0c83401d877de0e7'
      @secret_key = 'a9bb2d7f8cc00110'
      @authorize = Authorize.new(@api_key, @secret_key)
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
        @access_token = '0306646daca492b609132d4905edb822'
        @access_secret = '22070cec426cb925'
        @authorize.access_token = OAuth::Token.new(@access_token, @access_secret)
      end
        
      
      it "should authorized?" do
        @authorize.authorized?.should == true
      end

      it "get_people should works" do
        people = @authorize.get_people
        people.nil?.should == false
        people.uid.should == "41502874"
      end

      context "miniblog" do
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
      
      context "recommendation" do
        context "get_recommendation" do
          it "should work" do
            recommendation = @authorize.get_recommendation(28732532)
            recommendation.class.should == Douban::Recommendation
            recommendation.title.should == "推荐小组话题：理证：试论阿赖耶识存在之必然性"
          end
        end
      end
    end
  end
end
