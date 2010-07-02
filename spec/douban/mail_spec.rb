require File.join(File.dirname(__FILE__), '/../spec_helper')

require 'douban/mail'

module Douban
  describe Mail do
    before do
      @mails_string = %Q{<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <title>SJo1pHHJGmCx的收件箱</title>
        <author>
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </author>
        <entry>
                <id>http://api.douban.com/doumail/82937520</id>
                <title>hello2</title>
                <author>
                        <link href="http://api.douban.com/people/1018716" rel="self"/>
                        <link href="http://www.douban.com/people/lidaobing/" rel="alternate"/>
                        <name>LI Daobing</name>
                        <uri>http://api.douban.com/people/1018716</uri>
                </author>
                <published>2010-07-02T23:04:20+08:00</published>
                <link href="http://api.douban.com/doumail/82937520" rel="self"/>
                <link href="http://www.douban.com/doumail/82937520/" rel="alternate"/>
                <db:attribute name="unread">true</db:attribute>
        </entry>
        <entry>
                <id>http://api.douban.com/doumail/82937308</id>
                <title>hello</title>
                <author>
                        <link href="http://api.douban.com/people/1018716" rel="self"/>
                        <link href="http://www.douban.com/people/lidaobing/" rel="alternate"/>
                        <name>LI Daobing</name>
                        <uri>http://api.douban.com/people/1018716</uri>
                </author>
                <published>2010-07-02T23:02:57+08:00</published>
                <link href="http://api.douban.com/doumail/82937308" rel="self"/>
                <link href="http://www.douban.com/doumail/82937308/" rel="alternate"/>
                <db:attribute name="unread">true</db:attribute>
        </entry>
        <openSearch:itemsPerPage>10</openSearch:itemsPerPage>
        <openSearch:startIndex>1</openSearch:startIndex>
</feed>}

      @single_mail = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/doumail/82937520</id>
        <title>hello2</title>
        <author>
                <link href="http://api.douban.com/people/1018716" rel="self"/>
                <link href="http://www.douban.com/people/lidaobing/" rel="alternate"/>
                <name>LI Daobing</name>
                <uri>http://api.douban.com/people/1018716</uri>
        </author>
        <published>2010-07-02T23:04:20+08:00</published>
        <link href="http://api.douban.com/doumail/82937520" rel="self"/>
        <link href="http://www.douban.com/doumail/82937520/" rel="alternate"/>
        <content>world2</content>
        <db:attribute name="unread">false</db:attribute>
        <db:entity name="receiver">
                <link href="http://api.douban.com/people/41502874" rel="self"/>
                <link href="http://www.douban.com/people/41502874/" rel="alternate"/>
                <name>SJo1pHHJGmCx</name>
                <uri>http://api.douban.com/people/41502874</uri>
        </db:entity>
</entry>}

    end  

    it "should correct deserialize from string" do
      mail = Mail.new(@single_mail)
      mail.id.should == 'http://api.douban.com/doumail/82937520'
      mail.title.should == 'hello2'
      mail.author.class.should == Douban::Author
      mail.published.should == '2010-07-02T23:04:20+08:00'
      mail.link.should == {"self"=>"http://api.douban.com/doumail/82937520", "alternate"=>"http://www.douban.com/doumail/82937520/"}
      mail.content.should == "world2"
      mail.receiver.class.should == Author
    end

    it "should correct deserialize from REXML::Element" do
      feed = REXML::Document.new(@mails_string)
      mails = []
      REXML::XPath.each(feed, "//entry") do |entry|
        mails << Mail.new(entry)
      end
      mails.size.should == 2
      mails[0].id.should_not == mails[-1].id
    end
  end
end

