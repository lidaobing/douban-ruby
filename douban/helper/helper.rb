require'cgi'
require'iconv'
module Douban
=begin
class Hash
  def self
    self['self']
  end#end of self
  def icon
    self['icon']
  end#end of icon
  def alternate
    self['alternate']
    end#end of alternate
end
=end
def url_encode(str)
  CGI.escape(str)
end#end of url_encode

def utf8_to_gbk(str)
  iconv=Iconv.new("GBK//IGNORE","UTF-8//IGNORE")
  iconv.iconv(str)
end#end of utf82gbk

end#end of module