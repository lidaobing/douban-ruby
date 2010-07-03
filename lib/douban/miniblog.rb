require'rexml/document'
module Douban
 class Miniblog
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
        :author
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
    end
 end
end
