# frozen_string_literal: true

module Robottelo
  module Reporter
    module TestAttributes
      def method_added(meth)
        name = meth.to_s
        if name.starts_with?('test')
          (@__test_attributes__ ||= {})[name] = @__last_test_attributes__ if @__last_test_attributes__
        end
        @__last_test_attributes__ = {}
        super
      end

      def test_attributes(attr)
        @__last_test_attributes__ = attr
      end

      def get_test_attributes(meth)
        test_attr = {}
        test_attr = @__test_attributes__ if defined?(@__test_attributes__)
        meth_test_attr = test_attr[meth.to_s]
        meth_test_attr = {} if meth_test_attr.nil?
        meth_test_attr
      end
    end
  end
end
