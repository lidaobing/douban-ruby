# -*- encoding: UTF-8 -*-
require "spec_helper"

require 'douban/note'

module Douban
  describe Note do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/note/78970236</id>
        <title>a</title>
        <author>
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </author>
        <published>2010-07-03T19:42:11+08:00</published>
        <updated>2010-07-03T19:42:11+08:00</updated>
        <link href="http://api.douban.com/note/78970236" rel="self"/>
        <link href="http://www.douban.com/note/78970236/" rel="alternate"/>
        <summary>b</summary>
        <content>b</content>
        <db:attribute name="privacy">public</db:attribute>
        <db:attribute name="can_reply">yes</db:attribute>
        <db:attribute name="comments_count">0</db:attribute>
        <db:attribute name="recs_count">0</db:attribute>
</entry>}
    end
    
    it "should correct deserialize from string" do
      note = Note.new(@s)
      note.id.should == "http://api.douban.com/note/78970236"
      note.note_id.should == 78970236
      note.title.should == "a"
      note.author.class.should == Author
      note.published.should == "2010-07-03T19:42:11+08:00"
      note.updated.should == "2010-07-03T19:42:11+08:00"
      note.link.should == {"self"=>"http://api.douban.com/note/78970236", 
        "alternate"=>"http://www.douban.com/note/78970236/"}
      note.summary.should == "b"
      note.content.should == "b"
      note.attribute.should == {"can_reply"=>"yes", 
        "comments_count"=>"0", 
        "privacy"=>"public", 
        "recs_count"=>"0"}
    end
    
    it "should support ==" do
      Note.new(@s).should == Note.new(@s)
    end
    
    it "should correct deserialize from REXML::Element" do
      Note.new(REXML::Document.new(@s)).should == Note.new(@s)
    end
  end
end
      
    

