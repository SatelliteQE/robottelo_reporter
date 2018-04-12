# frozen_string_literal: true

require 'cgi'

module Robottelo
  module Reporter
    POLARION_ENV_NAME = 'POLARION_PROPERTIES'
    POLARION_CUSTOM_ENV_NAME = 'POLARION_CUSTOM_PROPERTIES'

    class PolarionProperties
      attr_reader :properties

      def initialize
        @properties = {}
        parse_main_properties
        parse_custom_properties
      end

      def to_xml(xml_builder)
        @properties.each do |name, value|
          xml_builder.property(name: name, value: value)
        end
      end

      private

      def parse_env_properties(env_name, prefix)
        prp = {}
        prp_string = ENV[env_name]
        if prp_string
          CGI.parse(prp_string).each do |key, value|
            prp["#{prefix}-#{key}"] = value[0] unless value.empty?
          end
        end
        prp
      end

      def parse_main_properties
        prp = parse_env_properties POLARION_ENV_NAME, 'polarion'
        response_key = 'polarion-response'
        if prp.key?(response_key)
          response_value = prp[response_key].split('=')
          prp["#{response_key}-#{response_value[0]}"] = response_value[1] if response_value.length == 2
          prp.delete(response_key)
        end
        @properties = @properties.merge(prp)
      end

      def parse_custom_properties
        prp = parse_env_properties POLARION_CUSTOM_ENV_NAME, 'polarion-custom'
        @properties = @properties.merge(prp)
      end
    end
  end
end
