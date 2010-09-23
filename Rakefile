require 'rubygems'
require 'bundler/setup'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require File.expand_path("../lib/douban/version", __FILE__)

ENV["SPEC_OPTS"] ||= "-f nested --color -b"
ENV["RDOC_OPTS"] ||= "-c UTF-8"


Spec::Rake::SpecTask.new :spec
task :default => :spec

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

desc 'build gem file'
task :build do
  system "gem build douban-ruby.gemspec"
end
 
desc 'upload gem file'
task :release => :build do
  system "gem push douban-ruby-#{Douban::VERSION}.gem"
end

