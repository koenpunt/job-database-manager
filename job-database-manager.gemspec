# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'job_database_manager/version'

Gem::Specification.new do |s|
  s.name        = 'job-database-manager'
  s.version     = JobDatabaseManager::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nicolas Rodriguez']
  s.email       = ['nrodriguez@jbox-web.com']
  s.homepage    = 'https://github.com/jbox-web/job-database-manager'
  s.summary     = %q{A Jenkins plugin to develop Jenkins Database plugins in Ruby.}
  s.description = %q{This plugin provides boilerplate code to write other Database Manager plugins}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
end
