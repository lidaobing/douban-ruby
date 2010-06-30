require File.join(File.dirname(__FILE__), '/../spec_helper')

module Douban
  describe Authorize do
    context "oauth login" do
      it "should return login url and request token" do
        authorize = Douban.authorize
        authorize.authorized?.should be_false
        authorize.get_authorize_url.should =~ %r{^http://.*oauth_token=[0-9a-f]{32}&oauth_callback=.*$}
        authorize.authorized?.should be_false
        authorize.request_token.token.should =~ /[0-9a-f]{32}/
        authorize.request_token.secret.should =~ /[0-9a-f]{16}/
      end
    end
    
    context "oauth verify" do
      before(:each) do
        @token = "a" * 32
        @secret = "b" * 16
        
        @access_token = "c"*32
        @access_secret = "d"*16
      end
      
      it "should support set request token" do
        authorize = Douban.authorize
        authorize.request_token = OAuth::Token.new(@token, @secret)
        authorize.request_token.kind_of?(OAuth::RequestToken).should == true
      end
      
      it "auth should works" do
        request_token_mock = mock("request_token")
        request_token_mock.stub!(:kind_of?).with(OAuth::RequestToken).and_return(true)
        request_token_mock.stub!(:get_access_token).and_return(
          OAuth::Token.new(@access_token, @access_secret)
        )
        
        authorize = Douban.authorize
        authorize.request_token = request_token_mock
        authorize.auth
        authorize.access_token.kind_of?(OAuth::AccessToken).should == true
        authorize.access_token.token.should == @access_token
        authorize.access_token.secret.should == @access_secret
      end
    end
    
    context "logged in with oauth" do
      it "should publish miniblog with html characters"
    end
  end
end
