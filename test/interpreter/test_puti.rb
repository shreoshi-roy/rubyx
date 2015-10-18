require_relative "helper"

class AddTest < MiniTest::Test
  include Ticker
  include AST::Sexp

  def test_puti
    @string_input = <<HERE
class Integer < Object
  Word digit( int rest )
    if( rest == 5 )
      return "5"
    end
    if( rest == 1 )
      return "1"
    end
    if( rest == 2 )
      return "2"
    end
    if( rest == 3 )
      return "3"
    end
    if( rest == 4 )
      return "4"
    end
  end
  Word add_string(Word str)
    int div
    div = self / 10
    int rest
    rest = self - div
    if( rest < 0)
      rest = self.digit( rest )
      str = str + rest
    else
      str = div.add_string(str)
    end
    return str
  end
  Word to_string()
    Word start = " "
    return add_string( start )
  end
end
class Object
  int main()
    5.to_string()
  end
end
HERE
    Virtual.machine.boot
    syntax  = Parser::Salama.new.parse_with_debug(@string_input)
    parts = Parser::Transform.new.apply(syntax)
    #puts parts.inspect
    Phisol::Compiler.compile( parts )

#    statements = Virtual.machine.boot.parse_and_compile @string_input
#    Phisol::Compiler.compile( statements , Virtual.machine.space.get_main )
    Virtual.machine.run_before "Register::CallImplementation"
    @interpreter = Interpreter::Interpreter.new
    @interpreter.start Virtual.machine.init
    #show_ticks # get output of what is
    ["Branch","LoadConstant","GetSlot","SetSlot","RegisterTransfer",
     "FunctionCall","SaveReturn","GetSlot","LoadConstant","SetSlot",
     "LoadConstant","SetSlot","RegisterTransfer","FunctionCall","SaveReturn",
     "LoadConstant","GetSlot","SetSlot","GetSlot","GetSlot",
     "SetSlot","LoadConstant","SetSlot","GetSlot","GetSlot",
     "SetSlot","RegisterTransfer","FunctionCall","SaveReturn","GetSlot",
     "LoadConstant","OperatorInstruction","GetSlot","SetSlot","GetSlot",
     "GetSlot","GetSlot","OperatorInstruction","GetSlot","SetSlot",
     "GetSlot","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "GetSlot","GetSlot","SetSlot","LoadConstant","SetSlot",
     "GetSlot","GetSlot","SetSlot","RegisterTransfer","FunctionCall",
     "SaveReturn","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "LoadConstant","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "LoadConstant","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "LoadConstant","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "LoadConstant","GetSlot","LoadConstant","OperatorInstruction","IsZeroBranch",
     "LoadConstant","NilClass"].each_with_index do |name , index|
    got = ticks(1)
    assert got.class.name.index(name) , "Wrong class for #{index+1}, expect #{name} , got #{got}"
end

  end
end
