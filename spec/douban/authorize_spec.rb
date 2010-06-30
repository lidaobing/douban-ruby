require File.join(File.dirname(__FILE__), '/../spec_helper')

module Douban
  describe Authorize do
    context "first login" do
      it "should return login url" do
        authorize = Douban.authorize
        authorize.authorized?.should be_false
        authorize.get_authorize_url.should =~ %r{^http://.*oauth_token=[0-9a-f]{32}&oauth_callback=.*$}
        authorize.authorized?.should be_false
      end
    end
    
    context "logged in with oauth" do
      it "should publish miniblog with html characters"
    end
  end
end
