
require_relative "helper"

module Vool
  class TestSimpleIfSlotMachine < MiniTest::Test
    include VoolCompile

    def setup
      @compiler = compile_main( "if(@a) ; @a = 5 ; else; @a = 6 ; end;return")
      @ins = @compiler.slot_instructions.next
    end

    def test_condition_compiles_to_check
      assert_equal TruthCheck , @ins.class , @ins
    end
    def test_condition_is_slot
      assert_equal SlotDefinition , @ins.condition.class , @ins
    end
    def test_label_after_check
      assert_equal Label , @ins.next.class , @ins
    end
    def test_label_last
      assert_equal Label , @ins.last.class , @ins
    end
    def test_array
      check_array [TruthCheck, Label, SlotLoad, Jump, Label ,
                    SlotLoad, Label, SlotLoad, ReturnJump,Label, ReturnSequence, Label], @ins
    end
  end
end
