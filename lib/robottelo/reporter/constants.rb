# frozen_string_literal: true

module Robottelo
  module Reporter
    TESTCASE_PROPERTIES_MAPPING = {
      pid: 'polarion-testcase-id'
    }.freeze
  end
  PROPERTY_PREFIX = 'polarion'
  PROPERTY_PREFIX_CUSTOM = 'polarion-custom'
  POLARION_ENV_NAME = 'POLARION_PROPERTIES'
  POLARION_CUSTOM_ENV_NAME = 'POLARION_CUSTOM_PROPERTIES'
end
