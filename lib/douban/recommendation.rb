require 'rexml/document'
require 'douban/author'

module Douban
  class Recommendation
    attr_accessor :id
    attr_accessor :title
    attr_accessor :author
    attr_accessor :published
    attr_accessor :content
    attr_accessor :content_type
    attr_accessor :category
    attr_accessor :comment
    attr_accessor :comments_count

    def initialize(entry="")
      doc = REXML::Document.new(entry)

      @id = REXML::XPath.first(doc, "//id/text()")

      @title = REXML::XPath.first(doc, "//title/text()")

      @author = REXML::XPath.first(doc, "//author")
      @author = Author.new(@author.to_s) if @author

      @published = REXML::XPath.first(doc, "//published/text()")

      @content = REXML::XPath.first(doc, "//content/text()")
      @content_type = REXML::XPath.first(doc, "//content/@type").value() rescue nil

      @category = REXML::XPath.first(doc, "//db:attribute[@name='category']/text()")
      @comment = REXML::XPath.first(doc, "//db:attribute[@name='comment']/text()")
      @comments_count = REXML::XPath.first(doc, "//db:attribute[@name='comment_count']/text()").to_i rescue 0
    end
  end
end
