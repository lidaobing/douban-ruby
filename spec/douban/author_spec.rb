# -*- encoding: UTF-8 -*-
require "spec_helper"

require 'douban/author'

module Douban
  describe Author do
    before do
      @s = <<eos
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
    <link href="http://api.douban.com/people/41502874" rel="self"/>
    <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
    <name>SJo1pHHJGmCx</name>
    <uri>http://api.douban.com/people/41502874</uri>
</entry>
eos
    end

    it "should correct deserialize" do
      author = Author.new(@s)
      author.uri.should == "http://api.douban.com/people/41502874"
      author.link.should == {"self"=>"http://api.douban.com/people/41502874",
        "alternate"=>"http://www.douban.com/people/41502874/"}
      author.name.should == "SJo1pHHJGmCx"
    end

    it "== should works" do
      Author.new(@s).should == Author.new(@s)
    end
  end
end

