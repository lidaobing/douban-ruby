module Douban
  module Equal
    def ==(other)
      return false unless other.kind_of? self.class
      self.class.attr_names.each do |attr|
        return false unless self.send(attr) == other.send(attr)
      end
      return true
    end
  end
end
