require 'rexml/document'
require 'active_support/core_ext/object/try'

require "douban/subject"
require 'douban/author'

module Douban
 class Mail
   class << self
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
      doc=REXML::XPath.first(REXML::Document.new(doc), "//entry") unless doc.kind_of?(REXML::Element)
      @title=REXML::XPath.first(doc,"./title").try :text
      @published=REXML::XPath.first(doc,"./published").try :text
      REXML::XPath.each(doc,"./link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      @id=REXML::XPath.first(doc,"./id").try :text
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
      @content=REXML::XPath.first(doc,"./content").try :text
      if author = REXML::XPath.first(doc,"./author")
        @author=Author.new(author)
      end
      if receiver = REXML::XPath.first(doc,"./db:entity[@name='receiver']")
        @receiver=Author.new(receiver)
      end
    end
 end
end

