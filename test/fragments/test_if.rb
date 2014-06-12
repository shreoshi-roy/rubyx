require_relative 'helper'

class TestIf < MiniTest::Test
  include Fragments

  def test_if
    @string_input = <<HERE
def itest(n)
      if( n < 12)
        "then".putstring()
      else
        "else".putstring()
      end
end

itest(20)
HERE
    @should = [0x0,0x40,0x2d,0xe9,0xc,0x0,0x53,0xe3,0x3,0x0,0x0,0xba,0x44,0x20,0x8f,0xe2,0x8,0x30,0xa0,0xe3,0x4,0x0,0x0,0xeb,0x2,0x0,0x0,0xea,0x3c,0x20,0x8f,0xe2,0x8,0x30,0xa0,0xe3,0x0,0x0,0x0,0xeb,0x0,0x80,0xbd,0xe8]
    @output = "else    "
    @target = [:Object , :itest]
    parse 
    write "if"
  end
end

