require'cgi'
require'iconv'
module Douban
  def url_encode(str)
    CGI.escape(str)
  end
  def url_decode(str)
    CGI.unescape(str)
  end
  def decode(str)
    CGI::unescapeHTML(str)
  end

  def utf8_to_gbk(str)
    iconv=Iconv.new("GBK//IGNORE","UTF-8//IGNORE")
    iconv.iconv(str)
  end
  def gbk_to_utf8(str)
    iconv=Iconv.new("UTF-8//IGNORE","GBK//IGNORE")
    iconv.iconv(str)
  end
end