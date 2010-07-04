require File.join(File.dirname(__FILE__), "/../spec_helper")

require 'douban/tag'

module Douban
  describe Tag do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
  <id>http://api.douban.com/book/tag/罗永浩</id>
  <title>罗永浩</title>
  <db:count>947</db:count>
</entry>}
    end

    it "should correct deserialize from string" do
      tag = Tag.new(@s)
      tag.id.should == "http://api.douban.com/book/tag/罗永浩"
      tag.title.should == "罗永浩"
      tag.count.should == 947
    end

  end
end

