require 'rexml/document'
require 'douban/subject'
require 'douban/author'
require 'douban/equal'

module Douban
 class Review
   include Douban::Equal
   
   class << self
     def attr_names
       [
        :updated,
        :subject,
        :author,
        :title,
        :summary,
        :link,
        :id,
        :rating,
        :published,
        :content
       ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
    def initialize(atom)
      doc = case atom
        when REXML::Document then atom.root
        when REXML::Element then atom
        else REXML::Document.new(atom).root
      end
      subject=REXML::XPath.first(doc,"./db:subject")
      @subject=Subject.new(subject) if subject
      author=REXML::XPath.first(doc,"./author")
      @author=Author.new(author.to_s) if author
      title=REXML::XPath.first(doc,"./title")
      @title=title.text if title
      updated=REXML::XPath.first(doc,"./updated")
      @updated=updated.text if updated
      @published=REXML::XPath.first(doc,"./published/text()").to_s
      summary=REXML::XPath.first(doc,"./summary")
      @summary=summary.text if summary
      @content = REXML::XPath.first(doc, "./content/text()").to_s
      REXML::XPath.each(doc,"./link") do |link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      id=REXML::XPath.first(doc,"./id")
      @id=id.text if id
      rating=REXML::XPath.first(doc,"./gd:rating")
     if rating
       @rating={}
       @rating['min']=rating.attributes['min']
       @rating['value']=rating.attributes['value']
       @rating['max']=rating.attributes['max']
     end
    end
    
    def review_id
      /\/(\d+)$/.match(@id)[1].to_i rescue nil
    end
  end
end
