require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/miniblog_comments'

module Douban
  describe MiniblogComments do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <title>嗷嗷嗷嗷 的回应</title>
        <author>
                <link href="http://api.douban.com/people/1966902" rel="self"/>
                <link href="http://www.douban.com/people/1966902/" rel="alternate"/>
                <link href="http://t.douban.com/icon/u1966902-13.jpg" rel="icon"/>
                <name>戳戳三文鱼</name>
                <uri>http://api.douban.com/people/1966902</uri>
        </author>
        <entry>
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
        </entry>
        <entry>
                <id>http://api.douban.com/miniblog/378744647/comment/12638491</id>
                <author>
                        <link href="http://api.douban.com/people/1966902" rel="self"/>
                        <link href="http://www.douban.com/people/1966902/" rel="alternate"/>
                        <link href="http://t.douban.com/icon/u1966902-13.jpg" rel="icon"/>
                        <name>戳戳三文鱼</name>
                        <uri>http://api.douban.com/people/1966902</uri>
                </author>
                <published>2010-07-07T03:20:17+08:00</published>
                <content>两脚都挺漂亮的，边裁今天不给力啊，吹掉荷兰和乌拉圭的不是越位的“越位”球</content>
        </entry>
        <openSearch:itemsPerPage>10</openSearch:itemsPerPage>
        <openSearch:startIndex>1</openSearch:startIndex>
        <openSearch:totalResults>2</openSearch:totalResults>
</feed>}
    end

    it "should correct deserialize from string" do
      comments = MiniblogComments.new(@s)
      comments.title.should == "嗷嗷嗷嗷 的回应"
      comments.author.class.should == Author
      comments.comments.size.should == 2
      comments.comments[0].class.should == MiniblogComment
      comments.page_info.should == PageInfo.new(10,1,2)
    end

    it "should correct deserialize from REXML::Document" do
      MiniblogComments.new(REXML::Document.new(@s)).should == MiniblogComments.new(@s)
    end

    it "should correct deserialize from REXML::Element" do
      MiniblogComments.new(REXML::Document.new(@s).root).should == MiniblogComments.new(@s)
    end
  end
end

