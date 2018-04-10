# frozen_string_literal: true

require 'minitest'
require 'builder'
require 'fileutils'
require 'cgi'

module Robottelo
  module Reporter
    PROPERTIES_MAPPING = {
      pid: 'polarion-testcase-id'
    }.freeze

    # The XML Test report builder
    class ResultsToXML
      def initialize
        @total_time = @assertions = @errors = @failures = @skips = 0
        @results = []
      end

      def test_attributes(result)
        test_attr = {}
        klass = result.class
        test_attr = klass.get_test_attributes(result.name) if klass.respond_to?(:get_test_attributes)
        test_attr
      end

      def record(result)
        @results << result
        on_new_record result
      end

      def build
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.instruct!
        builder.testsuite(errors: @errors, failures: @failures, name: 'minitest',
                          skips: @skips, tests: tests, time: @total_time.round(3)) do
          @results.each do |result|
            build_result_to_xml(builder, result)
          end
        end
      end

      private

      def tests
        @results.length
      end

      def on_new_record(result)
        @total_time += result.time
        @assertions += result.assertions
        case result.failure
        when MiniTest::Skip
          @skips += 1
        when MiniTest::UnexpectedError
          @errors += 1
        when MiniTest::Assertion
          @failures += 1
        end
      end

      def first_line(str)
        str.to_s.sub(/\n.*/m, '')
      end

      def failure_text(failure)
        backtrace = Minitest.filter_backtrace(failure.backtrace).join("\n")
        "#{failure.class}:\n" + backtrace + " (#{failure.class})\n"
      end

      def build_failure_to_xml(xml_builder, failure)
        label = failure.result_label.downcase
        label = 'failure' if label == 'error'
        xml_builder.tag!(label, type: failure.class.to_s, message: first_line(failure.message)) do
          xml_builder.text!(failure_text(failure))
        end
      end

      def build_result_properties_to_xml(xml_builder, result)
        test_attr = test_attributes result
        pid = test_attr[:pid]
        return if pid.nil?
        xml_builder.properties do
          PROPERTIES_MAPPING.each do |key, name|
            value = test_attr[key]
            xml_builder.property(name: name, value: value) unless value.nil?
          end
        end
      end

      def build_result_to_xml(xml_builder, result)
        xml_builder.testcase(classname: result.class.to_s, name: result.name, time: result.time.round(6)) do
          failure = result.failure
          build_failure_to_xml xml_builder, failure if failure
          build_result_properties_to_xml xml_builder, result
        end
      end
    end

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
        @xml_results_builder = ResultsToXML.new
      end

      def start
        # create the target dir if it does not exist
        FileUtils.mkdir_p File.dirname(@report_file_path)
      end

      def record(result)
        test_attr = @xml_results_builder.test_attributes(result)
        pid = test_attr[:pid]
        # record only if pid attribute exists
        @xml_results_builder.record result unless pid.nil?
      end

      def report
        File.open @report_file_path, 'w' do |f|
          f << @xml_results_builder.build
        end
        @io.puts "\nRobottelo Reporter build finished: #{@report_file_path}"
      end
    end
  end
end
