# frozen_string_literal: true

require 'test/test_helper'

class ExampleTesCase < MinitestWithAttributes
  test_attributes pid: '123456'
  def test_example_1
    assert true
  end

  test_attributes pid: '123457'
  def test_example_2
    assert true
  end
end
