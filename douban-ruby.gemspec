# -*- encoding: utf-8 -*-
require File.expand_path("../lib/douban/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "douban-ruby"
  s.version     = Douban::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['LI Daobing', 'Hoooopo']
  s.email       = ['lidaobing@gmail.com', 'hoooopo@gmail.com']
  s.homepage    = "http://rubygems.org/gems/douban-ruby"
  s.summary     = "douban ruby client. including OAuth support."
  s.description = "Douban API reference: http://www.douban.com/service/apidoc/reference/"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "douban-ruby"

  s.add_dependency "oauth"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rcov'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
