require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'douban'

Hoe.spec 'douban' do
  developer "Hoooopo", "hoooopo@gmail.com"
  developer "LI Daobing", "lidaobing@gmail.com"
end

Hoe.plugin :minitest
Hoe.plugin :git
Hoe.plugin :gemcutter

desc "Simple require on packaged files to make sure they are all there"
task :verify => :package do
  # An error message will be displayed if files are missing
  if system %(ruby -e "require 'pkg/douban-#{Douban::VERSION}/lib/douban'")
    puts "\nThe library files are present"
  end
end

task :release => :verify

ENV["SPEC_OPTS"] ||= "-f nested"
