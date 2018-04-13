# frozen_string_literal: true

if RUBY_VERSION > '2.5'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter,
                          Coveralls::SimpleCov::Formatter]
  SimpleCov.start do
    minimum_coverage 70
    maximum_coverage_drop 0.1
    refuse_coverage_drop
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'robottelo/reporter/attributes'
require 'minitest/autorun'

class MinitestWithAttributes < Minitest::Test
  extend Robottelo::Reporter::TestAttributes
end
