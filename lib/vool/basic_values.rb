module Vool
  class Constant < Expression
    #gobble it up
    def each(&block)
    end
  end

  class IntegerConstant < Constant
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def slot_definition(method)
      return Mom::SlotDefinition.new(Mom::IntegerConstant.new(@value) , [])
    end
    def ct_type
      Parfait.object_space.get_class_by_name(:Integer).instance_type
    end
    def to_s
      value.to_s
    end
    def each(&block)
    end
  end
  class FloatConstant < Constant
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def ct_type
      true
    end
  end
  class TrueConstant < Constant
    def ct_type
      Parfait.object_space.get_class_by_name(:True).instance_type
    end
    def slot_definition(method)
      return Mom::SlotDefinition.new(Parfait.object_space.true_object , [])
    end
  end
  class FalseConstant < Constant
    def ct_type
      Parfait.object_space.get_class_by_name(:False).instance_type
    end
    def slot_definition(method)
      return Mom::SlotDefinition.new(Parfait.object_space.false_object , [])
    end
  end
  class NilConstant < Constant
    def ct_type
      Parfait.object_space.get_class_by_name(:Nil).instance_type
    end
    def slot_definition(method)
      return Mom::SlotDefinition.new(Parfait.object_space.nil_object , [])
    end
  end
  class SelfExpression < Expression
    attr_reader :my_type
    def initialize(type = nil)
      @my_type = type
    end
    def slot_definition(in_method)
      @my_type = in_method.for_type
      Mom::SlotDefinition.new(:message , [:receiver])
    end
    def ct_type
      @my_type
    end
    def to_s
      "self"
    end
  end
  class SuperExpression < Statement
  end
  class StringConstant < Constant
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def slot_definition(method)
      return Mom::SlotDefinition.new(Mom::StringConstant.new(@value),[])
    end
    def ct_type
      Parfait.object_space.get_class_by_name(:Word).instance_type
    end
  end
  class SymbolConstant < StringConstant
    def ct_type
      Parfait.object_space.get_class_by_name(:Word).instance_type
    end
  end
end