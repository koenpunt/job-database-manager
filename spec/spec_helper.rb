require 'rubygems'
require 'simplecov'
require 'rspec'
require 'codeclimate-test-reporter'
require 'pullreview/coverage_reporter'

## Configure SimpleCov
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter,
  PullReview::Coverage::Formatter
])

## Start Simplecov
SimpleCov.start do
  add_filter '/spec/'
end

## Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.fail_fast = false
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'job_database_manager'


class FooAdapter < JobDatabaseManager::DbAdapter::AbstractAdapter
end


def build_adapter
  launcher = double('launcher')
  FooAdapter.new(launcher, 'foo', 'pass', '127.0.0.1', 3306, '/usr/bin/mysql')
end


def build_db_creator(opts = {})
  klass = Class.new do
    include JobDatabaseManager::DbCreator
  end
  options = {
    'job_db_name' => 'foo_db',
    'job_db_user' => 'foo_user',
    'job_db_pass' => 'foo_pass'
  }.merge(opts)
  klass.new(options)
end


def build_db_destroyer(opts = {})
  klass = Class.new do
    include JobDatabaseManager::DbDestroyer
  end
  options = {
    'job_db_name' => 'foo_db',
    'job_db_user' => 'foo_user',
    'job_db_pass' => 'foo_pass'
  }.merge(opts)
  klass.new(options)
end
