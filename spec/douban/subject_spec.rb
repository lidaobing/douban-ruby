# -*- encoding: UTF-8 -*-
require "spec_helper"

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
    
    context "book" do
      it "should support isbn" do
        book = Book.new(@s)
        book.isbn10.should == "7040048809"
        book.isbn13.should == "9787040048803"
        book.isbn.should == book.isbn13
      end
    end
    
    context "movie" do
      before do
        @s_movie = %Q{<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
        <id>http://api.douban.com/movie/subject/1858711</id>
        <title>Toy Story 3</title>
        <category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#movie"/>
        <author>
                <name>Lee Unkrich</name>
        </author>
        <link href="http://api.douban.com/movie/subject/1858711" rel="self"/>
        <link href="http://movie.douban.com/subject/1858711/" rel="alternate"/>
        <link href="http://t.douban.com/spic/s4207957.jpg" rel="image"/>
        <summary>自从11年前玩具们所经历的大冒险后，玩具们安然无恙的度过了好几个年头。转眼间，玩具们的主人安迪（约翰·莫里斯 John Morris 配音）已经成为一个青少年，也即将离家去展开他的大学生涯。伍迪（汤姆·汉克斯 Tom Hanks 配音）与巴斯（蒂姆·艾伦 Tim Allen 配音）以及其他的玩具们也都人心惶惶，深怕这个他们内心最恐惧被丢弃的一天即将来临。这一天，安迪的妈妈来到安迪的房间，询问他将如何处置这些伴他渡过童年的玩具们，并且要求安迪在离家前要把这些东西处理好，如果没有将要留下的玩具放置阁楼收藏，她就会把这些玩具处理掉。安迪在妈妈的逼迫下，再次打开他的玩具箱，童年回忆涌上心头，他根本舍不得将任何一件玩具丢掉，所以将所有的玩具都放入大黑袋子中，准备将它们放置阁楼，但正要将袋子放入阁楼的同时，安迪被妹妹呼唤去帮忙，就在阴错阳差之下，妈妈误以为黑袋子里的玩具是要丢弃，所以就将玩具们全数捐给阳光托儿所。
玩具们来到阳光托儿所原本以为来到了天堂，托儿所里有非常好的规划还有更多玩具的新朋友，而且玩具们也都兴奋的期待能够再与小主人一同玩乐。殊不知托儿所的小朋友一抵达教室的时候才是噩梦的开始，被拉扯、被吞食、被支解几乎是天天上演的戏码。另外托儿所还有黑暗的地下组织，玩具们人人自危。
同时安迪发现珍藏的玩具被不心丢弃了，正心急如焚的寻找，玩具们得知小主人安迪在寻找他们，即将一起展开史上最大规模的逃亡行动，还有更多的冒险等着他们，玩具们是否能成功回到小主人安迪的身边呢？
本片在视听效果上全面追赶潮流，大规模投放3D版本。此外，本片还成为了杜比7.1版本音响系统第一部应用的影片。</summary>
        <db:attribute name="country">美国</db:attribute>
        <db:attribute name="website">http://disney.go.com/toystory/</db:attribute>
        <db:attribute name="writer">Michael Arndt</db:attribute>
        <db:attribute name="writer">John Lasseter</db:attribute>
        <db:attribute name="title">Toy Story 3</db:attribute>
        <db:attribute name="director">Lee Unkrich</db:attribute>
        <db:attribute lang="zh_CN" name="aka">玩具总动员3</db:attribute>
        <db:attribute name="pubdate">2010-06-16 (中国大陆)</db:attribute>
        <db:attribute name="imdb">http://www.imdb.com/title/tt0435761/</db:attribute>
        <db:attribute name="language">英语</db:attribute>
        <db:attribute name="language">西班牙语</db:attribute>
        <db:attribute name="cast">Tom Hanks</db:attribute>
        <db:attribute name="cast">Tim Allen</db:attribute>
        <db:attribute name="cast">Joan Cusack</db:attribute>
        <db:attribute name="cast">Ned Beatty</db:attribute>
        <db:attribute name="cast">Don Rickles</db:attribute>
        <db:attribute name="cast">Michael Keaton</db:attribute>
        <db:attribute name="aka">反斗奇兵3</db:attribute>
        <db:attribute name="aka">玩具总动员3</db:attribute>
        <db:tag count="6515" name="动画"/>
        <db:tag count="4202" name="Pixar"/>
        <db:tag count="3054" name="美国"/>
        <db:tag count="2653" name="3D"/>
        <db:tag count="2003" name="迪斯尼"/>
        <db:tag count="1123" name="2010"/>
        <db:tag count="963" name="成长"/>
        <db:tag count="879" name="喜剧"/>
        <gd:rating average="9.1" max="10" min="0" numRaters="18675"/>
</entry>}
      end
      
      it "should support imdb" do
        movie = Movie.new(@s_movie)
        movie.imdb.should == "tt0435761"
      end
    end
  end
end
  
