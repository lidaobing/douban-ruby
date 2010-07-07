require'rexml/document'

require 'douban/author'
require 'douban/equal'

module Douban
  class MiniblogComment
    include Douban::Equal
    class << self
      def attr_names
        [
          :id,
          :author,
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
      @id = REXML::XPath.first(doc, "./id/text()").to_s rescue nil
      author = REXML::XPath.first(doc, "./author")
      @author = Author.new(author) if author
      @published = REXML::XPath.first(doc, "./published/text()").to_s rescue nil
      @content = REXML::XPath.first(doc, "./content/text()").to_s rescue nil
    end
  end
end
