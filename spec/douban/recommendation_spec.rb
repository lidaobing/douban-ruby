require File.join(File.dirname(__FILE__), "/../spec_helper")

module Douban
  describe Recommendation do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/recommendation/28732532</id>
        <title>推荐小组话题：理证：试论阿赖耶识存在之必然性</title>
        <author>
                <link href="http://api.douban.com/people/1418737" rel="self"/>
                <link href="http://www.douban.com/people/1418737/" rel="alternate"/>
                <link href="http://t.douban.com/icon/u1418737-20.jpg" rel="icon"/>
                <name>白微</name>
                <uri>http://api.douban.com/people/1418737</uri>
        </author>
        <published>2010-07-01T19:41:33+08:00</published>
        <content type="html"><![CDATA[推荐小组<a href="http://www.douban.com/group/165983/">唯識與中觀</a>的话题<a href="http://www.douban.com/group/topic/9754580/">理证：试论阿赖耶识存在之必然性</a>]]></content>
        <db:attribute name="category">topic</db:attribute>
        <db:attribute name="comment"></db:attribute>
        <db:attribute name="comments_count">0</db:attribute>
</entry>
}
    end

    it "should correct deserialize from string" do
      recommendation = Recommendation.new(@s)
      recommendation.id.should == "http://api.douban.com/recommendation/28732532"
      recommendation.recommendation_id.should == 28732532
      recommendation.title.should == "推荐小组话题：理证：试论阿赖耶识存在之必然性"
      recommendation.author.class.should == Douban::Author
      recommendation.published.should == "2010-07-01T19:41:33+08:00"
      recommendation.content.should == '推荐小组<a href="http://www.douban.com/group/165983/">唯識與中觀</a>的话题<a href="http://www.douban.com/group/topic/9754580/">理证：试论阿赖耶识存在之必然性</a>'
      recommendation.content_type.class.should == String
      recommendation.content_type.should == "html"
      recommendation.category.should == "topic"
      recommendation.comment.should == ""
      recommendation.comments_count.should == 0
    end

    it "should correct deserialize from REXML::Element" do
      Recommendation.new(REXML::Document.new(@s)).should == Recommendation.new(@s)
    end
  end
end

