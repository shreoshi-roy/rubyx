require_relative "helper"

module Sol
  class TestClassDef < MiniTest::Test
    include SlotMachine
    include SolCompile

    def class_main
      <<-eos
        class Space
          def self.one_plus()
            return 1 + 1
          end
          def main(arg)
            return Space.one_plus
          end
        end
      eos
    end

    def setup
      source = "class Integer<Data4;def +(other);X.int_operator(:+);end;end;" + class_main
      ret = RubyX::RubyXCompiler.new(RubyX.default_test_options).ruby_to_slot(source)
      @ins = ret.compilers.find_compiler_name(:main).slot_instructions.next
    end
    def test_array
      check_array [MessageSetup,ArgumentTransfer,SimpleCall,SlotLoad,
                    ReturnJump,Label, ReturnSequence , Label] , @ins
    end

    def test_any
      assert_equal SlotMachine::MessageSetup , @ins.class
    end
    def test_no_arg
      assert_equal SlotMachine::ArgumentTransfer,  @ins.next(1).class
      assert_equal 0,  @ins.next(1).arguments.length
    end
    def test_call_two
      assert_equal SimpleCall,  @ins.next(2).class
    end
  end
end
