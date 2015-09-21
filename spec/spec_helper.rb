require 'rubygems'
require 'simplecov'
require 'rspec'
require 'codeclimate-test-reporter'

## Configure SimpleCov
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

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
