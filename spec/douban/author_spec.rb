require File.join(File.dirname(__FILE__), '/../spec_helper')

module Douban
  describe Author do
    it "should correct deserialize" do
      s = <<eos
  <author>
    <link href="http://api.douban.com/people/41502874" rel="self"/>
    <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
    <name>SJo1pHHJGmCx</name>
    <uri>http://api.douban.com/people/41502874</uri>
  </author>
eos
      author = Author.new(s)
      author.uri.should == "http://api.douban.com/people/41502874"
      author.link.should == {"self"=>"http://api.douban.com/people/41502874", 
        "alternate"=>"http://www.douban.com/people/41502874/"}
      author.name.should == "SJo1pHHJGmCx"
    end
  end
end

