require 'rexml/document'

module Douban
  class PageInfo < Struct.new(:items_per_page, :start_index, :total_results)
    def initialize(*args)
      if args.size != 1
        super(*args)
        return
      end

      atom = args[0]
      doc = case atom
            when REXML::Document then atom.root
            when REXML::Element then atom
            else REXML::Document.new(atom).root
            end

      self.items_per_page = REXML::XPath.first(doc, "./openSearch:itemsPerPage/text()").to_s.to_i rescue nil
      self.start_index = REXML::XPath.first(doc, "./openSearch:startIndex/text()").to_s.to_i rescue nil
      self.total_results = REXML::XPath.first(doc, "./openSearch:totalResults/text()").to_s.to_i rescue nil
    end
  end
end
