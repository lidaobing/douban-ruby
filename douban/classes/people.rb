require'rexml/document'
module Douban
=begin
class People
  attr_accessor :id
  attr_accessor:location
  attr_accessor:title
  attr_accessor:link
  attr_accessor :content
  attr_accessor :uid
  def initialize(entry=nil)
    if entry
      @link={}
    entry.each do |e|
        if e.name=="link"
        @link[e.attributes['rel']]=e.attributes['href']
        else
          instance_variable_set("@#{e.name}",e.text) 
        end#end of if
       self
        end#end of each
      end#end of initizlize
    end#end of if
=end
class People
    include Douban
    
    class << self
      def attr_names
        [ 
          :id,
          :location,
          :title,
          :link,
          :content,
          :uid
        ]
      end
    end
    attr_reader :friends
    attr_names.each do |attr|
      attr_accessor attr
    end
  
    def initialize(doc="")
      begin
    doc= REXML::Document.new(doc)
       %w[id title content db:location db:uid].each do |attr|
        eval <<-RUBY
          REXML::XPath.each(doc, "//entry/#{attr}") do |e|
            @#{attr.split(':').pop} = e.text if e.text
          end
        RUBY
    end
      REXML::XPath.each(doc, "//entry/link[@*]") do |e|
        @link ||= {}
        @link["#{e.attributes['rel']}"] = e.attributes['href']
      end
      rescue
      ensure
       self
      end
     
    end
end#end of class
end#end of module
