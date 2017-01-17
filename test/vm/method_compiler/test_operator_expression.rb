require_relative "helper"

module Register
  class TestOps < MiniTest::Test
    include ExpressionHelper
    include AST::Sexp

    def setup
      Register.machine.boot
      @root = :operator_value
      @output = Register::RegisterValue
    end

    def operators
      [:+ , :- , :* , :/ , :== ]
    end
    def test_ints
      operators.each do |op|
        @input = s(:operator_value, op , s(:int, 2), s(:int, 3))
        check
      end
    end
    def test_local_int
      Parfait.object_space.get_main.add_local(:bar , :Integer)
      @input    = s(:operator_value, :+, s(:local, :bar), s(:int, 3))
      check
    end
    def test_int_local
      Parfait.object_space.get_main.add_local(:bar , :Integer)
      @input    = s(:operator_value, :+, s(:int, 3), s(:local, :bar))
      check
    end

    def test_field_int
      add_space_field(:bro,:Integer)
      @input = s(:operator_value, :+, s(:field_access,s(:receiver, s(:known, :self)), s(:field, s(:ivar, :bro))), s(:int, 3))
      check
    end

    def test_int_field
      add_space_field(:bro,:Integer)
      @input = s(:operator_value, :+, s(:int, 3), s(:field_access, s(:receiver, s(:known, :self)), s(:field,s(:ivar, :bro))))
      check
    end
  end
end