# frozen_string_literal: true

require 'minitest'
require 'fileutils'
require 'robottelo/reporter/result'
require 'robottelo/reporter/results'

module Robottelo
  module Reporter
    # The Minitest Report Runner
    class Runner < ::Minitest::AbstractReporter
      attr_accessor :io
      attr_accessor :options

      def initialize(io = $stdout, options = {})
        @io = io
        @options = options
        report_file_name = ENV['ROBOTTELO_REPORT_NAME'] || "robottelo-results.xml"
        ci_reports_path = ENV['CI_REPORTS'] || File.expand_path("#{Dir.getwd}/test/reports")
        report_dir = "#{ci_reports_path}/robottelo"
        report_file_path = ENV['ROBOTTELO_REPORT_PATH'] || "#{report_dir}/#{report_file_name}"
        @report_file_path = File.expand_path(report_file_path)
        @io.puts 'Robottelo Reporter initialization'
        @xml_results = Robottelo::Reporter::ResultsToXML.new
        @last_test_properties = {}
        @last_test_klass = nil
        @last_test_meth = nil
      end

      def start
        # create the target dir if it does not exist
        FileUtils.mkdir_p File.dirname(@report_file_path)
      end

      def prerecord(klass, name)
        # This is the last chance to have access to the test class
        @last_test_properties = Robottelo::Reporter.test_attributes klass, name
        @last_test_klass = klass.to_s
        @last_test_meth = name
      end

      def record(result)
        pid = @last_test_properties[:pid]
        # record only if pid attribute exists
        unless pid.nil?
          test_result = Robottelo::Reporter::TestResult.new(
            @last_test_klass,
            @last_test_meth,
            result.time,
            result.assertions,
            result.failures,
            @last_test_properties
          )
          @xml_results.record test_result
        end
        @last_test_properties = {}
      end

      def report
        File.open @report_file_path, 'w' do |f|
          f << @xml_results.build
        end
        @io.puts "\nRobottelo Reporter build finished: #{@report_file_path}"
      end
    end
  end
end
