require_relative "../helper"

module Risc
  class TestTranslator < MiniTest::Test

    def setup
      @machine = Risc.machine.boot
      @translator = Arm::Translator.new
    end

    def test_translate_label
      label = Parfait.object_space.get_main.risc_instructions
      assert @translator.translate(label) , label
    end

    def test_translate_space
      @assembler = Assembler.new(@machine , Collector.collect_space)
      assert @machine.translate_arm
    end
  end
end
