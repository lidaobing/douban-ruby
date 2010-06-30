require'rexml/document'
module Douban
class Tag
    include Douban
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
      doc=REXML::Document.new(atom)
      id=REXML::XPath.first(doc,"//entry/id")
      @id=id.text if id
      title=REXML::XPath.first(doc,"//entry/title")
      @title=title.text if title
      count=REXML::XPath.first(doc,"//entry/db:count")
      @count=count.text if count
    end
end
end
