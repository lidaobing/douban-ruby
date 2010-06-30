require File.join(File.dirname(__FILE__), '/../spec_helper')

module Douban
  describe Miniblog do
    it "should correct deserialize" do
      s = <<eos
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
  <id>http://api.douban.com/miniblog/374100199</id>
  <title><![CDATA[<b>单元测试0.921892231299059]]></title>
  <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#miniblog.saying"/>
  <author>
    <link href="http://api.douban.com/people/41502874" rel="self"/>
    <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
    <name>SJo1pHHJGmCx</name>
    <uri>http://api.douban.com/people/41502874</uri>
  </author>
  <published>2010-06-30T19:27:41+08:00</published>
  <content type="html">&amp;lt;b&amp;gt;单元测试0.921892231299059</content>
  <db:attribute name="comments_count">0</db:attribute>
</entry>      
eos
      miniblog = Douban::Miniblog.new(s)
      miniblog.id.should == "http://api.douban.com/miniblog/374100199"
      miniblog.title.should == '<b>单元测试0.921892231299059'
      miniblog.category.should == {"term"=>"http://www.douban.com/2007#miniblog.saying", "scheme"=>"http://www.douban.com/2007#kind"}
      miniblog.published.should == "2010-06-30T19:27:41+08:00"
      miniblog.link.should == nil
      miniblog.content.should == "&lt;b&gt;单元测试0.921892231299059"
      miniblog.attribute.should == {"comments_count" => "0"}
      miniblog.author.nil?.should == false
    end
  end
end
