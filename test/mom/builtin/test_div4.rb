require_relative "helper"

module Mom
  module Builtin
    class TestIntDiv4Risc < BootTest
      def setup
        super
        @method = get_int_compiler(:div4)
      end
      def test_compile
        assert_equal Risc::MethodCompiler , @method.to_risc.class
      end
      def test_risc_length
        assert_equal 47 , @method.to_risc.risc_instructions.length
      end
    end
  end
end