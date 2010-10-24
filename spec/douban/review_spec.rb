# -*- encoding: UTF-8 -*-
require "spec_helper"

require 'douban/review'

module Douban
  describe Review do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/review/3391729</id>
        <title>douban-ruby 单元测试</title>
        <author>
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </author>
        <published>2010-07-03T20:55:45+08:00</published>
        <updated>2010-07-03T20:55:45+08:00</updated>
        <link href="http://api.douban.com/review/3391729" rel="self"/>
        <link href="http://www.douban.com/review/3391729/" rel="alternate"/>
        <link href="http://api.douban.com/book/subject/1088840" rel="http://www.douban.com/2007#subject"/>
        <content>douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试douban-ruby 单元测试</content>
        <db:subject>
                <id>http://api.douban.com/book/subject/1088840</id>
                <title>无机化学(下)/高等学校教材</title>
                <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#book"/>
                <author>
                        <name>武汉大学、吉林大学</name>
                </author>
                <link href="http://api.douban.com/book/subject/1088840" rel="self"/>
                <link href="http://book.douban.com/subject/1088840/" rel="alternate"/>
                <link href="http://img2.douban.com/spic/s1075910.jpg" rel="image"/>
                <link href="http://api.douban.com/collection/266907549" rel="collection"/>
                <db:attribute name="author">武汉大学、吉林大学</db:attribute>
                <db:attribute name="isbn10">7040048809</db:attribute>
                <db:attribute name="isbn13">9787040048803</db:attribute>
                <db:attribute name="price">26.5</db:attribute>
                <db:attribute name="publisher">高等教育出版社</db:attribute>
                <db:attribute name="pubdate">2005-1-1</db:attribute>
        </db:subject>
        <gd:rating max="5" min="1" value="5"/>
</entry>}
    end
    
    it "should correct deserialize from string" do
      review = Review.new(@s)
      review.id.should == "http://api.douban.com/review/3391729"
      review.title.should == "douban-ruby 单元测试"
      review.author.class.should == Author
      review.published.should == "2010-07-03T20:55:45+08:00"
      review.updated.should == "2010-07-03T20:55:45+08:00"
      review.link.should == {"self"=>"http://api.douban.com/review/3391729",
        "alternate"=>"http://www.douban.com/review/3391729/",
        "http://www.douban.com/2007#subject"=>"http://api.douban.com/book/subject/1088840"}
      review.content.should == "douban-ruby 单元测试"*10
      review.subject.kind_of?(Subject).should == true
      review.rating.should == {"max"=>"5", "value"=>"5", "min"=>"1"}
    end
    
    it "should support ==" do
      Review.new(@s).should == Review.new(@s)
    end
    
    it "should support deserialize from REXML::Document" do
      Review.new(REXML::Document.new(@s)).should == Review.new(@s)
    end

    it "should support deserialize from REXML::Element" do
      Review.new(REXML::Document.new(@s).root).should == Review.new(@s)
    end
  end
end



