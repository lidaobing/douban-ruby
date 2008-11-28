require'rexml/document'
module Douban
  
  class Book
    class << self 
      def attr_names
        [
          :id,
          :title,
          :category,
          :author,
          :link,
          :summary,
          :attribute,
          :tag,
          :rating
        ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
   def initialize(atom='')
     begin
      doc=REXML::Document.new(atom)
      @id=REXML::XPath.first(doc,"//id").text
      @title=REXML::XPath.first(doc,"//title").text
      @category={}
      @category['term']=REXML::XPath.first(doc,"//category").attributes['term']
      @category['scheme']=REXML::XPath.first(doc,"//category").attributes['scheme']
      REXML::XPath.each(doc,"//db:tag") do |tag|
        @tag||={}
        @tag[tag.attributes['name']]=tag.attributes['count']
      end
      @author={}
      name=REXML::XPath.first(doc,"//author/name")
      if !name.nil?
        @author['name']=name.text
      else
        nil
      end
      uri=REXML::XPath.first(doc,"//author/uri")
      if !uri.nil?
        @author['uri']=uri.text
      else
        nil
      end
      link=REXML::XPath.first(doc,"//author/link")
      if !link.nil?
        @author['link']=link.text
      else
        nil
      end
      summary=REXML::XPath.first(doc,"//summary")
      if !summary.nil?
        @summary=summary.text
      end
      REXML::XPath.each(doc,"//link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      REXML::XPath.each(doc,"//db:attribute") do |attribute|
        @attribute||={}
        @attribute[attribute.attributes['name']]=attribute.text
      end
      @rating={}
      rating=REXML::XPath.first(doc,"//gd:rating")
      if !rating.nil?
        @rating['min']=rating.attributes['min']
        @rating['numRaters']=rating.attributes['numRaters']
        @rating['average']=rating.attributes['average']
        @rating['max']=rating.attributes['max']
      end
     rescue
     ensure
      self
     end
     
   end
 end
 end
 

    