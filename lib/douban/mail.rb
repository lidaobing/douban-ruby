require 'rexml/document'
require "douban/subject"
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
    def initialize(doc)
      doc=REXML::Document.new(doc) unless doc.kind_of?(REXML::Element)
      title=REXML::XPath.first(doc,"./title")
      @title=title.text if title
      published=REXML::XPath.first(doc,"./published")
      @published=published.text if published
      REXML::XPath.each(doc,"./link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      id=REXML::XPath.first(doc,"./id")
      @id=id.text if id
      REXML::XPath.each(doc,"./db:attribute") do |attr|
        @attribute||={}
        @attribute[attr.attributes['name']]=attr.text
      end
      category=REXML::XPath.first(doc,"./category")
      if category
        @category={}
        @category['term']=category.attributes['term']
        @category['scheme']=category.attributes['scheme']
      end
      content=REXML::XPath.first(doc,"./content")
      @content=content.text if content
      author=REXML::XPath.first(doc,"./author")
      @author=Author.new(author.to_s) if author
      receiver=REXML::XPath.first(doc,"./db:entity[@name='receiver']")
      @receiver=Author.new(receiver.to_s) if receiver
    end
 end
end

