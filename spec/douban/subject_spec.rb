require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/subject'

module Douban
  describe Subject do
    before do
      @s = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/book/subject/1088840</id>
        <title>无机化学(下)/高等学校教材</title>
        <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#book"/>
        <author>
                <name>武汉大学、吉林大学</name>
        </author>
        <link href="http://api.douban.com/book/subject/1088840" rel="self"/>
        <link href="http://book.douban.com/subject/1088840/" rel="alternate"/>
        <link href="http://img2.douban.com/spic/s1075910.jpg" rel="image"/>
        <link href="http://api.douban.com/collection/266907549" rel="collection"/>
        <db:attribute name="author">武汉大学、吉林大学</db:attribute>
        <db:attribute name="isbn10">7040048809</db:attribute>
        <db:attribute name="isbn13">9787040048803</db:attribute>
        <db:attribute name="title">无机化学(下)/高等学校教材</db:attribute>
        <db:attribute name="pages">1185</db:attribute>
        <db:attribute name="price">26.5</db:attribute>
        <db:attribute name="publisher">高等教育出版社</db:attribute>
        <db:attribute name="binding">平装</db:attribute>
        <db:attribute name="pubdate">2005-1-1</db:attribute>
        <db:tag count="23" name="化学"/>
        <db:tag count="16" name="无机化学"/>
        <db:tag count="10" name="教材"/>
        <db:tag count="6" name="武汉大学"/>
        <db:tag count="3" name="Chemistry"/>
        <db:tag count="2" name="科学"/>
        <db:tag count="2" name="吉林大学"/>
        <db:tag count="1" name="无机"/>
        <gd:rating average="8.0" max="10" min="0" numRaters="50"/>
</entry>}
    end
    
    it "should correct deserialize from string" do
      subject = Subject.new(@s)
      subject.id.should == "http://api.douban.com/book/subject/1088840"
      subject.subject_id.should == 1088840
      subject.title.should == "无机化学(下)/高等学校教材"
      subject.category.should == {"term"=>"http://www.douban.com/2007#book", "scheme"=>"http://www.douban.com/2007#kind"}
      subject.author.class.should == Author
      subject.link.should == {"self"=>"http://api.douban.com/book/subject/1088840", 
        "alternate"=>"http://book.douban.com/subject/1088840/", 
        "image"=>"http://img2.douban.com/spic/s1075910.jpg", 
        "collection"=>"http://api.douban.com/collection/266907549"}
      subject.summary.should == nil
      subject.attribute.should == {"pubdate"=>"2005-1-1", "price"=>"26.5", "isbn10"=>"7040048809", "title"=>"无机化学(下)/高等学校教\346\235\220", "author"=>"武汉大学、吉林大\345\255\246", "isbn13"=>"9787040048803", "publisher"=>"高等教育出版社", 
        "pages"=>"1185", "binding"=>"平装"}
      subject.tag.size.should == 8
      subject.tag[0].class.should == Tag
      subject.rating.should == {"max"=>"10", "average"=>"8.0", "min"=>"0", "numRaters"=>"50"}
    end
    
    it "should support ==" do
      Subject.new(@s).should == Subject.new(@s)
    end
    
    it "should correct deserialize from REXML::Document" do
      Subject.new(REXML::Document.new(@s)).should == Subject.new(@s)
    end

    it "should correct deserialize from REXML::Element" do
      Subject.new(REXML::Document.new(@s).root).should == Subject.new(@s)
    end
  end
end
  
