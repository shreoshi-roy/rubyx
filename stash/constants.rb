module Register

  class Constant < ::Register::Object
  end
  class TrueConstant < Constant
  end
  class FalseConstant < Constant
  end
  class NilConstant < Constant
  end

  # another abstract "marker" class (so we can check for it)
  # derived classes are Boot/Meta Class and StringConstant
  class ObjectConstant < Constant
#    def type
#      Soml::Reference
#    end
    def clazz
      raise "abstract #{self}"
    end
  end

  class IntegerConstant < Constant
    def initialize int
      @integer = int
    end
    attr_reader :integer
    def type
      :Integer
    end
    def fits_u8?
      integer >= 0 and integer <= 255
    end
  end

end