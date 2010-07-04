require File.join(File.dirname(__FILE__), '/spec_helper')

require 'douban'

describe Douban do
  it "should has a VERSION" do
    Douban::VERSION.should =~ /^\d+\.\d+\.\d+(\.dev)?$/
  end
end
