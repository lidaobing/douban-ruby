require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'douban'

ENV["SPEC_OPTS"] ||= "-f nested --color -b"
ENV["RDOC_OPTS"] ||= "-c UTF-8"

Hoe.spec 'douban-ruby' do
  developer "LI Daobing", "lidaobing@gmail.com"
  developer "Hoooopo", "hoooopo@gmail.com"
  extra_deps << ['oauth']
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

namespace :spec do
  desc "Run specs with RCov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb' ]
    t.rcov = true
    t.rcov_opts = ['--exclude' , 'gems,spec' ]
  end
end

Rake::RDocTask.new do |rd|
  rd.options << "--charset" << "UTF-8"
end
