require 'rexml/document'
require 'douban/subject'
require 'douban/author'

module Douban
  class Collection

    include Douban::Equal

    class << self
      def attr_names
        [
          :tag,
          :updated,
          :subject,
          :author,
          :title,
          :summary,
          :link,
          :id,
          :rating,
          :status
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
      @title=title.text if !title.nil?
      updated=REXML::XPath.first(doc,"./updated")
      @updated=updated.text if updated
      @summary = REXML::XPath.first(doc, "./summary/text()").to_s
      @status = REXML::XPath.first(doc, "./db:status/text()").to_s
      @link = Hash.new
      REXML::XPath.each(doc, "./link") do |e|
        @link[e.attributes["rel"]] = e.attributes["href"]
      end
      id=REXML::XPath.first(doc,"./id")
      @id=id.text if id
      REXML::XPath.each(doc,"./db:tag") do |tag|
        @tag||=[]
        @tag<< tag.attributes['name']
      end
      rating=REXML::XPath.first(doc,"./db:rating")
      if rating
        @rating={}
        @rating['min']=rating.attributes['min']
        @rating['value']=rating.attributes['value']
        @rating['max']=rating.attributes['max']
      end
    end

    def collection_id
      /\/(\d+)$/.match(@id)[1].to_i rescue nil
    end
  end
end

