require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/miniblog_comment'

module Douban
  describe MiniblogComment do
    before do
      @s = %Q{<entry>
                <id>http://api.douban.com/miniblog/378744647/comment/12638415</id>
                <author>
                        <link href="http://api.douban.com/people/3918884" rel="self"/>
                        <link href="http://www.douban.com/people/Ben.Dan/" rel="alternate"/>
                        <link href="http://t.douban.com/icon/u3918884-8.jpg" rel="icon"/>
                        <name>積み木</name>
                        <uri>http://api.douban.com/people/3918884</uri>
                </author>
                <published>2010-07-07T03:19:07+08:00</published>
                <content>都爱远射哈哈</content>
        </entry>}
    end

    it "should correct deserialize from string" do
      comment = MiniblogComment.new(@s)
      comment.id.should == "http://api.douban.com/miniblog/378744647/comment/12638415"
      comment.author.class.should == Author
      comment.published.should == "2010-07-07T03:19:07+08:00"
      comment.content.should == "都爱远射哈哈"
      comment.miniblog_id.should == 378744647
      comment.comment_id.should == 12638415
    end

    it "should correct deserialize from REXML::Document" do
      MiniblogComment.new(REXML::Document.new(@s)).should == MiniblogComment.new(@s)
    end

    it "should correct deserialize from REXML::Element" do
      MiniblogComment.new(REXML::Document.new(@s).root).should == MiniblogComment.new(@s)
    end
  end
end


