#atom=<<-ruby
#<?xml version="1.0" encoding="UTF-8"?>
#<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
#    <id>http://api.douban.com/doumail/20152801</id>
#    <title>test</title>
#    <author>
#        <link href="http://api.douban.com/people/1057620" rel="self"/>
#        <link href="http://www.douban.com/people/aka/" rel="alternate"/>
#        <link href="http://otho.douban.com/icon/u1057620-20.jpg" rel="icon"/>
#        <name>胖胖的大头鱼</name>
#        <uri>http://api.douban.com/people/1057620</uri>
#    </author>
#    <published>2008-12-26T16:23:01+08:00</published>
#    <link href="http://api.douban.com/doumail/20152801" rel="self"/>
#    <link href="http://www.douban.com/doumail/20152801/" rel="alternate"/>
#    <content>test</content>
#    <db:attribute name="unread">false</db:attribute>
#    <db:entity name="recevier">
#        <link href="http://api.douban.com/people/1057620" rel="self"/>
#        <link href="http://www.douban.com/people/aka/" rel="alternate"/>
#        <link href="http://otho.douban.com/icon/u1057620-20.jpg" rel="icon"/>
#        <name>胖胖的大头鱼</name>
#        <uri>http://api.douban.com/people/1057620</uri>
#    </db:entity>
#</entry>
#ruby
require'rexml/document'
require"subjects.rb"
module Douban
 class Mail
   class <<self
     def attr_names
       [
        :id,
        :title,
        :category,
        :published,
        :link,
        :content,
        :attribute,
        :author,
        :receiver
       ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
    def initialize(atom)
      doc=REXML::Document.new(atom)
      title=REXML::XPath.first(doc,"//entry/title")
      @title=title.text if title
      published=REXML::XPath.first(doc,"//entry/published")
      @published=published.text if published
      REXML::XPath.each(doc,"//entry/link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      id=REXML::XPath.first(doc,"//entry/id")
      @id=id.text if id
      REXML::XPath.each(doc,"//entry/db:attribute") do |attr|
        @attribute||={}
        @attribute[attr.attributes['name']]=attr.text
      end
      category=REXML::XPath.first(doc,"//entry/category")
      if category
        @category={}
        @category['term']=category.attributes['term']
        @category['scheme']=category.attributes['scheme']
      end
      content=REXML::XPath.first(doc,"//entry/content")
      @content=content.text if content
      author=REXML::XPath.first(doc,"//entry/author")
      @author=Author.new(author.to_s) if author
      receiver=REXML::XPath.first(doc,"//entry/db:entity[@name='receiver']")
      @receiver=Author.new(receiver.to_s) if receiver
    end
 end
end

