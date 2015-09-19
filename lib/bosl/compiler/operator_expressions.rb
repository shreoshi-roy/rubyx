module Bosl
  module Compiler
#    operator attr_reader  :operator, :left, :right
    def self.compile_operator expression, method
      call = Ast::CallSiteExpression.new(expression.operator , [expression.right] , expression.left )
      Compiler.compile(call, method)
    end

    def self.compile_assign expression, method
      puts "assign"
      puts expression.inspect
      name , value = *expression
      name = name.to_a.first
      v = self.compile(value , method )
      index = method.ensure_local( name )
      method.source.add_code Virtual::Set.new(Virtual::FrameSlot.new(index ) , v )
    end

  end
end
