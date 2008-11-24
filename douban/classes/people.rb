require'rexml/document'
module Douban
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
    
    
      
      
end#end of class
end#end of module
