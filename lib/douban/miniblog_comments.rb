require'rexml/document'

require 'douban/author'
require 'douban/miniblog_comment'
require 'douban/page_info'

module Douban
  class MiniblogComments < Struct.new(:title, :author, :comments, :page_info)
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
      self.title = REXML::XPath.first(doc, "./title/text()").to_s rescue nil
      author = REXML::XPath.first(doc, "./author")
      self.author = Author.new(author) if author
      self.comments = []
      REXML::XPath.each(doc, "./entry") do |entry|
        self.comments << MiniblogComment.new(entry)
      end
      self.page_info = PageInfo.new(doc)
    end
  end
end
