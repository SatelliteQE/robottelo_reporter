# frozen_string_literal: true

require 'builder'
require 'robottelo/reporter/polarion'
require 'robottelo/reporter/result'

module Robottelo
  module Reporter
    # The XML Test report builder
    class ResultsToXML
      def initialize
        @total_time = @assertions = @errors = @failures = @skips = 0
        @results = []
        @polarion_properties = PolarionProperties.new
      end

      def record(result)
        @results << result
        on_new_record result
      end

      def build
        xml_builder = Builder::XmlMarkup.new(indent: 2)
        xml_builder.instruct!
        xml_builder.testsuites do
          xml_builder.properties do
            @polarion_properties.to_xml xml_builder
          end
          xml_builder.testsuite(errors: @errors, failures: @failures, name: 'minitest',
                                skips: @skips, tests: tests, time: @total_time.round(5)) do
            @results.each do |result|
              result.to_xml(xml_builder)
            end
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
    end
  end
end
