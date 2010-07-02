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
      @id = REXML::XPath.first(doc, ".//id/text()").to_s
      @author = REXML::XPath.first(doc, ".//author")
      @author = Author.new(@author.to_s) if @author
      @published = REXML::XPath.first(doc, ".//published/text()").to_s
      @content = REXML::XPath.first(doc, ".//content/text()").to_s
    end

    def recommendation_id
      /recommendation\/(\d+)\/comment/.match(@id)[1].to_i rescue nil
    end

    def comment_id
      /\/(\d+)$/.match(@id)[1].to_i rescue nil
    end
  end
end
      
