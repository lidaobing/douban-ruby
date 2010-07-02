require 'douban/author'
require 'douban/equal'

module Douban
  class RecommendationComment
    include Douban::Equal

    class << self
      def attr_names
        @@attr_names ||= %w{id author published content}.map {|x| x.to_sym}
      end
    end

    attr_names.each do |x|
      attr_accessor x
    end

    def initialize(entry="")
      doc = entry.kind_of?(REXML::Element) ? entry : REXML::Document.new(entry)
      @id = REXML::XPath.first(doc, ".//id/text()")
      @author = REXML::XPath.first(doc, ".//author")
      @author = Author.new(@author.to_s) if @author
      @published = REXML::XPath.first(doc, ".//published/text()")
      @content = REXML::XPath.first(doc, ".//content/text()")
    end
  end
end
      
