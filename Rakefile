require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks
require 'rspec/core/rake_task'
require 'rake/rdoctask'
require File.expand_path("../lib/douban/version", __FILE__)

ENV["SPEC_OPTS"] ||= "-f nested --color -b"
ENV["RDOC_OPTS"] ||= "-c UTF-8"


RSpec::Core::RakeTask.new :spec
task :default => :spec

RSpec::Core::RakeTask.new :rcov do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude' , 'gems,spec' ]
end

Rake::RDocTask.new do |rd|
  rd.options << "--charset" << "UTF-8"
end
