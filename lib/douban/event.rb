require'rexml/document'
module Douban
  class Event
    class<<self
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
      doc=REXML::Document.new(atom)
      id=REXML::XPath.first(doc,"//entry/id")
      @id=id.text if id
      title=REXML::XPath.first(doc,"//entry/title")
      @title=title.text if title
      @category={}
      category=REXML::XPath.first(doc,"//entry/category")
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
      summary=REXML::XPath.first(doc,"//entry/summary")
      @summary=summary.text if summary
      content=REXML::XPath.first(doc,"//entry/content")
      @content=content.text if content
      REXML::XPath.each(doc,"//entry/link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      REXML::XPath.each(doc,"//entry/db:attribute") do |attribute|
        @attribute||={}
        @attribute[attribute.attributes['name']]=attribute.text
      end
      location=REXML::XPath.first(doc,"//entry/db:location")
      @location=location.text if location
      @when={}
      time=REXML::XPath.first(doc,"//entry/gd:when")
      if time
       @when['startTime']=time.attributes['startTime']
       @when['endTime']=time.attributes['endTime']
     end
     where=REXML::XPath.first(doc,"//entry/gd:where")
     @where=where.attributes['valueString'] if where
   end
 end
 end

    