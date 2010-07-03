require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/event'

module Douban
  describe Event do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/event/12171445</id>
        <title>a</title>
        <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#event.party"/>
        <author>
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </author>
        <link href="http://api.douban.com/event/12171445" rel="self"/>
        <link href="http://www.douban.com/event/12171445/" rel="alternate"/>
        <summary>b</summary>
        <content>b</content>
        <db:attribute name="invite_only">no</db:attribute>
        <db:attribute name="can_invite">yes</db:attribute>
        <db:attribute name="participants">1</db:attribute>
        <db:attribute name="wishers">0</db:attribute>
        <db:attribute name="album">29707279</db:attribute>
        <db:attribute name="status">participate</db:attribute>
        <db:location id="beijing">北京</db:location>
        <gd:when endTime="2010-07-07T22:39:38+08:00" startTime="2010-07-02T22:39:38+08:00"/>
        <gd:where valueString="北京 大山子798艺术区 IT馆"/>
</entry>}
    end

    it "should correct deserialize from string" do
      event = Event.new(@s)
      event.event_id.should == 12171445
      event.id.should == "http://api.douban.com/event/12171445"
      event.title.should == "a"
      event.category.should == {"term"=>"http://www.douban.com/2007#event.party", "scheme"=>"http://www.douban.com/2007#kind"}
      event.author.class.should == Author
      event.link.should == {"self"=>"http://api.douban.com/event/12171445", "alternate"=>"http://www.douban.com/event/12171445/"}
      event.summary.should == "b"
      event.content.should == "b"
    end

    it "should support ==" do
      Event.new(@s).should == Event.new(@s)
    end

    it "should correct deserialize from REXML::Element" do
      Event.new(REXML::Document.new(@s)).should == Event.new(@s)
    end
  end
end

