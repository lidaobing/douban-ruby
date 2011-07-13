require 'rexml/document'
require 'douban/equal'
require 'douban/author'

module Douban
  class Event
    include Douban::Equal
    class << self
      def attr_names
        [
          :id,
          :title,
          :category,
          :author,
          :link,
          :summary,
          :content,
          :attribute,
          :location,
          :when,
          :where
        ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
    def initialize(atom='')
      doc = case atom
    when REXML::Document then atom.root
    when REXML::Element then atom
    else REXML::Document.new(atom).root
    end

      @id=REXML::XPath.first(doc,"./id/text()").to_s
      title=REXML::XPath.first(doc,"./title")
      @title=title.text if title
      @category={}
      category=REXML::XPath.first(doc,"./category")
      @category['term']=category.attributes['term'] if category
      @category['scheme']=category.attributes['scheme'] if category
      @author||=Author.new
      name=REXML::XPath.first(doc,"//author/name")
      @author.name=name.text if name
      uri=REXML::XPath.first(doc,"//author/uri")
      @author.uri=uri.text if uri
      REXML::XPath.each(doc,"//author/link") do |link|
        @author.link||={}
        @author.link[link.attributes['rel']]=link.attributes['href']
      end
      summary=REXML::XPath.first(doc,"./summary")
      @summary=summary.text if summary
      content=REXML::XPath.first(doc,"./content")
      @content=content.text if content
      REXML::XPath.each(doc,"./link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      REXML::XPath.each(doc,"./db:attribute") do |attribute|
        @attribute||={}
        @attribute[attribute.attributes['name']]=attribute.text
      end
      location=REXML::XPath.first(doc,"./db:location")
      @location=location.text if location
      @when={}
      time=REXML::XPath.first(doc,"./gd:when")
      if time
       @when['startTime']=time.attributes['startTime']
       @when['endTime']=time.attributes['endTime']
     end
     where=REXML::XPath.first(doc,"./gd:where")
     @where=where.attributes['valueString'] if where
   end

   def event_id
     /\/(\d+)$/.match(@id)[1].to_i rescue nil
   end
 end
 end

