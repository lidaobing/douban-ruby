require 'spec_helper'

require 'douban/page_info'

module Douban
  describe PageInfo do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <openSearch:itemsPerPage>10</openSearch:itemsPerPage>
        <openSearch:startIndex>1</openSearch:startIndex>
        <openSearch:totalResults>2</openSearch:totalResults>
</feed>}
    end

    it "should correct deserialize from string" do
      PageInfo.new(@s).should == PageInfo.new(10,1,2)
    end
    it "should correct deserialize from REXML::Document" do
      PageInfo.new(REXML::Document.new(@s)).should == PageInfo.new(10,1,2)
    end
    it "should correct deserialize from REXML::Element" do
      PageInfo.new(REXML::Document.new(@s).root).should == PageInfo.new(10,1,2)
    end
  end
end
