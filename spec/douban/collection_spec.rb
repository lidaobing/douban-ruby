require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/collection'

module Douban
  describe Collection do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/collection/266618947</id>
        <title>SJo1pHHJGmCx 看过 Cowboy Bebop</title>
        <author>
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </author>
        <updated>2010-07-02T21:48:29+08:00</updated>
        <link href="http://api.douban.com/collection/266618947" rel="self"/>
        <link href="http://api.douban.com/movie/subject/1424406" rel="http://www.douban.com/2007#subject"/>
        <summary>a</summary>
        <db:status>watched</db:status>
        <db:subject>
                <id>http://api.douban.com/movie/subject/1424406</id>
                <title>Cowboy Bebop</title>
                <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#movie"/>
                <author>
                        <name>渡边信一郎</name>
                </author>
                <link href="http://api.douban.com/movie/subject/1424406" rel="self"/>
                <link href="http://movie.douban.com/subject/1424406/" rel="alternate"/>
                <link href="http://t.douban.com/spic/s2975009.jpg" rel="image"/>
                <link href="http://api.douban.com/collection/266618947" rel="collection"/>
                <db:attribute name="website">http://www.cowboybebop.org/</db:attribute>
                <db:attribute name="country">Japan</db:attribute>
                <db:attribute name="pubdate">1998-04-03</db:attribute>
                <db:attribute name="language">日语</db:attribute>
                <db:attribute name="imdb">http://www.imdb.com/title/tt0213338/</db:attribute>
                <db:attribute lang="zh_CN" name="aka">赏金猎人</db:attribute>
                <db:attribute name="cast">山寺宏一</db:attribute>
                <db:attribute name="cast">石冢运升</db:attribute>
                <db:attribute name="cast">林原めぐみ</db:attribute>
                <db:attribute name="cast">多田葵</db:attribute>
        </db:subject>
        <db:tag name="tag"/>
        <gd:rating max="5" min="1" value="5"/>
</entry>}
    end

    it "should correct deserialize string" do
      collection = Collection.new(@s)
      collection.id.should == "http://api.douban.com/collection/266618947"
      collection.title.should == "SJo1pHHJGmCx 看过 Cowboy Bebop"
      collection.author.class.should == Author
      collection.updated.should == "2010-07-02T21:48:29+08:00"
      collection.link.should == {"self" => "http://api.douban.com/collection/266618947",
        "http://www.douban.com/2007#subject" => "http://api.douban.com/movie/subject/1424406"}
      collection.tag.should == ["tag"]
      collection.subject.kind_of?(Subject).should == true
      collection.summary.should == "a"
      collection.status.should == "watched"
    end

    it "should support ==" do
      Collection.new(@s).should == Collection.new(@s)
    end

    it "should correct deserialize REXML::Element" do
      Collection.new(REXML::Document.new(@s)).should == Collection.new(@s)
    end
  end
end

