require'rexml/document'
module Douban
class People
    include Douban
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
      doc=REXML::Document.new(atom)
      id=REXML::XPath.first(doc,"//entry/id")
      @id=id.text if id
      content=REXML::XPath.first(doc,"//entry/content")
      @content=content.text if content
      title=REXML::XPath.first(doc,"//entry/title")
      @title=title.text if title
      location=REXML::XPath.first(doc,"//entry/db:location")
      @location=location.text if location
      uid=REXML::XPath.first(doc,"//entry/db:uid")
      @uid=uid.text if uid
      REXML::XPath.each(doc,"//entry/link") do|link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
    end
end
end
