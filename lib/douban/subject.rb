require 'rexml/document'
require 'douban/tag'
require 'douban/equal'
module Douban
  class Subject
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
      doc = atom.kind_of?(REXML::Element) ? atom : REXML::Document.new(atom)
      id=REXML::XPath.first(doc,".//id")
      @id=id.text if id
      title=REXML::XPath.first(doc,".//title")
      @title=title.text if title
      @category={}
      category=REXML::XPath.first(doc,".//category")
      @category['term']=category.attributes['term'] if category
      @category['scheme']=category.attributes['scheme'] if category
      REXML::XPath.each(doc,".//db:tag") do |tag|
        @tag||=[]
        t=Tag.new
        t.title=tag.attributes['name']
        t.count=tag.attributes['count']
        @tag<<t
      end
      @author||=Author.new
      name=REXML::XPath.first(doc,".//author/name")
      @author.name=name.text if name
      uri=REXML::XPath.first(doc,".//author/uri")
      @author.uri=uri.text if uri
      REXML::XPath.each(doc,".//author/link") do |link|
        @author.link||={}
        @author.link[link.attributes['rel']]=link.attributes['href']
      end
      summary=REXML::XPath.first(doc,".//summary")
      @summary=summary.text if summary
      REXML::XPath.each(doc,".//link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      REXML::XPath.each(doc,".//db:attribute") do |attribute|
        @attribute||={}
        @attribute[attribute.attributes['name']]=attribute.text
      end
      @rating={}
      rating=REXML::XPath.first(doc,".//gd:rating")
      if rating
        @rating['min']=rating.attributes['min'] 
        @rating['numRaters']=rating.attributes['numRaters'] 
        @rating['average']=rating.attributes['average'] 
        @rating['max']=rating.attributes['max']
      end
   end
 end
  class Movie<Subject
    def initialize(atom)
      super(atom)
    end
  end
  class Book<Subject
    def initialize(atom)
      super(atom)
    end
  end
  class Music<Subject
    def initialize(atom)
      super(atom)
    end
  end
 end

    
