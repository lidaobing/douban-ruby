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
      doc=REXML::Document.new(doc) unless doc.kind_of?(REXML::Element)
      title=REXML::XPath.first(doc,"//entry/title")
      @title=title.text if title
      published=REXML::XPath.first(doc,"//entry/published")
      @published=published.text if published
      updated=REXML::XPath.first(doc,"//entry/updated")
      @updated=updated.text if updated
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
      content=REXML::XPath.first(doc,"//entry/content")
      @content=content.text if content
      summary=REXML::XPath.first(doc,"//entry/summary")
      @summary=summary.text if summary
      author=REXML::XPath.first(doc,"//entry/author")
      @author=Author.new(author.to_s) if author
    end
    
    def note_id
      /\/(\d+)$/.match(@id)[1].to_i rescue nil
    end
 end
end
