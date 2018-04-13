# frozen_string_literal: true

require 'test_helper'

class AttributesTest < MinitestWithAttributes
  test_attributes pid: '123456', 'title': '123456 attributes'
  def test_attributes_binded__to_test_method
    assert_equal({pid: '123456', 'title': '123456 attributes'}, AttributesTest.get_test_attributes(name))
  end
end
