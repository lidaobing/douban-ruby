require 'rexml/document'
require 'douban/author'
require 'douban/equal'

module Douban
  class Recommendation
    include Douban::Equal

    class << self
      def attr_names
        @@attr_names ||= %w(id title author published content content_type category comment comments_count).map {|x| x.to_sym}
      end
    end

    attr_names.each do |attr|
      attr_accessor attr
    end

    def initialize(entry="")
      if entry.kind_of? REXML::Element
        doc = entry
      else
        doc = REXML::Document.new(entry)
      end

      @id = REXML::XPath.first(doc, ".//id/text()")

      @title = REXML::XPath.first(doc, ".//title/text()")

      @author = REXML::XPath.first(doc, ".//author")
      @author = Author.new(@author.to_s) if @author

      @published = REXML::XPath.first(doc, ".//published/text()")

      @content = REXML::XPath.first(doc, ".//content/text()")
      @content_type = REXML::XPath.first(doc, ".//content/@type").value() rescue nil

      @category = REXML::XPath.first(doc, ".//db:attribute[@name='category']/text()")
      @comment = REXML::XPath.first(doc, ".//db:attribute[@name='comment']/text()")
      @comments_count = REXML::XPath.first(doc, ".//db:attribute[@name='comment_count']/text()").to_i rescue 0
    end
  end
end
