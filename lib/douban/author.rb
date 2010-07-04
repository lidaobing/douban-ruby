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
    def initialize(atom=nil)
      doc = case atom
        when REXML::Document then atom.root
        when REXML::Element then atom
        when nil then nil
        else REXML::Document.new(atom).root
      end

      unless doc.nil?
        REXML::XPath.each(doc,"./link") do|link|
          @link||={}
          @link[link.attributes['rel']]=link.attributes['href']
        end
        name=REXML::XPath.first(doc,"./name")
        @name=name.text if name
        uri=REXML::XPath.first(doc,"./uri")
        @uri=uri.text if uri
      end
    end
  end
end

