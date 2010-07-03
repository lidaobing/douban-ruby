require'rexml/document'

require 'douban/author'
require 'douban/equal'

module Douban
 class Note
   include Douban::Equal
   
   class << self
     def attr_names
       [
        :id,
        :title,
        :summary,
        :updated,
        :published,
        :link,
        :content,
        :attribute,
        :author
       ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
    def initialize(doc)
      doc = REXML::Document.new(doc).root unless doc.kind_of?(REXML::Element)
      doc = doc.root if doc.kind_of?(REXML::Document)
      
      title=REXML::XPath.first(doc,"./title")
      @title=title.text if title
      published=REXML::XPath.first(doc,"./published")
      @published=published.text if published
      updated=REXML::XPath.first(doc,"./updated")
      @updated=updated.text if updated
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
      content=REXML::XPath.first(doc,"./content")
      @content=content.text if content
      summary=REXML::XPath.first(doc,"./summary")
      @summary=summary.text if summary
      author=REXML::XPath.first(doc,"./author")
      @author=Author.new(author.to_s) if author
    end
    
    def note_id
      /\/(\d+)$/.match(@id)[1].to_i rescue nil
    end
 end
end
