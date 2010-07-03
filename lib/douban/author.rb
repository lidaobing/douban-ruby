require 'rexml/document'
require 'douban/equal'

module Douban
  class Author
    include Douban::Equal

    class << self
      def attr_names
        [
          :uri,
          :link,
          :name
        ]
      end
    end
    attr_names.each do |attr|
      attr_accessor attr
    end
    def initialize(doc='')
      doc=REXML::Document.new(doc) unless doc.kind_of?(REXML::Element)
      REXML::XPath.each(doc,"//link") do|link|
        @link||={}
        @link[link.attributes['rel']]=link.attributes['href']
      end
      name=REXML::XPath.first(doc,"//name")
      @name=name.text if name
      uri=REXML::XPath.first(doc,"//uri")
      @uri=uri.text if uri
    end
  end
end
