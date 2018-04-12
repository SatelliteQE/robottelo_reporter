# frozen_string_literal: true

module Robottelo
  module Reporter
    TESTCASE_PROPERTIES_MAPPING = {
      pid: 'polarion-testcase-id'
    }.freeze

    TestResult = Struct.new(:klass, :name, :time, :assertions, :failures, :properties) do
      def failure
        failures.first
      end

      def failure_text(failure)
        "#{failure.class}:\n#{failure.message}\n#{failure.location}\n"
      end

      def first_line(str)
        str.to_s.sub(/\n.*/m, '')
      end

      def properties_to_xml(xml_builder)
        pid = properties[:pid]
        return if pid.nil?
        xml_builder.properties do
          TESTCASE_PROPERTIES_MAPPING.each do |key, name|
            value = properties[key]
            xml_builder.property(name: name, value: value) unless value.nil?
          end
        end
      end

      def failure_to_xml(xml_builder, failure)
        label = failure.result_label.downcase
        label = 'failure' if label == 'error'
        xml_builder.tag!(label, type: failure.class.to_s, message: first_line(failure.message)) do
          xml_builder.text!(failure_text(failure))
        end
      end

      def to_xml(xml_builder)
        xml_builder.testcase(classname: klass, name: name, time: time.round(5)) do
          failure_to_xml xml_builder, failure if failure
          properties_to_xml xml_builder
        end
      end
    end
  end
end
