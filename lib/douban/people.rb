require 'rexml/document'

require 'douban/equal'

module Douban
  class People
    include Douban::Equal
    class << self
      def attr_names
        [
          :id,
          :location,
          :title,
          :link,
          :content,
          :uid
        ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end

    def initialize(atom="")
      doc = case atom
        when REXML::Document then atom.root
        when REXML::Element then atom
        else REXML::Document.new(atom).root
      end

      id=REXML::XPath.first(doc,"./id")
      @id=id.text if id
      content=REXML::XPath.first(doc,"./content")
      @content=content.text if content
      title=REXML::XPath.first(doc,"./title")
      @title=title.text if title
      location=REXML::XPath.first(doc,"./db:location")
      @location=location.text if location
      uid=REXML::XPath.first(doc,"./db:uid")
      @uid=uid.text if uid
      REXML::XPath.each(doc,"./link") do|link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
    end
end
end

