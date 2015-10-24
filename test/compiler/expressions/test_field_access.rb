require_relative "compiler_helper"

module Register
  class TestFields < MiniTest::Test
    include CompilerHelper

    def setup
      Register.machine.boot
    end

    def test_field_not_defined
      @root = :field_access
      @string_input = <<HERE
self.a
HERE
      assert_raises(RuntimeError) { check }
    end

    def test_field
      Register.machine.space.get_class_by_name(:Object).object_layout.add_instance_variable(:bro)
      @root = :field_access
      @string_input = <<HERE
self.bro
HERE
      @output = Register::RegisterValue
      check
    end

    def test_local
      Register.machine.space.get_main.ensure_local(:bar , :Integer)
      @root = :name
      @string_input    = 'bar '
      @output = Register::RegisterValue
      check
    end

    def test_args
      Register.machine.space.get_main.arguments.push Parfait::Variable.new(:Integer , :bar)
      @root = :name
      @string_input    = 'bar '
      @output = Register::RegisterValue
      check
    end

  end
end