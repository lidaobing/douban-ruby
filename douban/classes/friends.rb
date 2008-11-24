module Douban
class Friends
  attr_reader:title
  attr_reader:author
  attr_reader:startIndex
  attr_reader:totalResults
  attr_reader:people
  def initialize(option={})
    @title=option['title']
    @author=option['author']
    @startIndex=option['startIndex']
    @totalResults=option['totalResults']
    @people=option['people']
  end
  
end#end of class
end#end of module