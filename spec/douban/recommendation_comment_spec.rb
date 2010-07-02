require File.join(File.dirname(__FILE__), "/../spec_helper")

module Douban
  describe RecommendationComment do
    before do
      @s = %Q{<entry>
        <id>http://api.douban.com/recommendation/3673470/comment/178441</id>
        <author>
            <link href="http://api.douban.com/people/1177592" rel="self"/>
            <link href="http://www.douban.com/people/Autorun/" rel="alternate"/>
            <link href="http://t.douban.com/icon/u1177592-15.jpg" rel="icon"/>
            <name>Autorun</name>
            <uri>http://api.douban.com/people/1177592</uri>
        </author>
        <published>2008-11-07T10:19:54+08:00</published>
        <content>对，这是刚捡回来的时候，呵呵，现在已经成大屁妹了</content>
    </entry>}
    end

    it "should correct deserialize from string" do
      comment = RecommendationComment.new(@s)
      comment.id.should == "http://api.douban.com/recommendation/3673470/comment/178441"
      comment.author.class.should == Douban::Author
      comment.published.should == "2008-11-07T10:19:54+08:00"
      comment.content.should == "对，这是刚捡回来的时候，呵呵，现在已经成大屁妹了"    

      comment.recommendation_id.should == 3673470
      comment.comment_id.should == 178441
    end

    it "should correct deserialize from REXML::Element" do
      RecommendationComment.new(REXML::Document.new(@s)).should == RecommendationComment.new(@s)
    end
  end
end

