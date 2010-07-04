require 'rexml/document'

require 'douban/equal'

module Douban
  class Tag
    include Douban::Equal
    class << self
      def attr_names
        [
          :id,
          :count,
          :title
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
        when nil then nil
        else REXML::Document.new(atom).root
      end

      unless doc.nil?
        id=REXML::XPath.first(doc,"./id")
        @id=id.text if id
        title=REXML::XPath.first(doc,"./title")
        @title=title.text if title
        @count=REXML::XPath.first(doc,"./db:count/text()").to_s.to_i rescue nil
      end
    end
  end
end

