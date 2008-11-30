require'cgi'
require'iconv'
module Douban
=begin
class Hash
  def self
    self['self']
  end
  def icon
    self['icon']
  end
  def alternate
    self['alternate']
    end
end
=end
def url_encode(str)
  CGI.escape(str)
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