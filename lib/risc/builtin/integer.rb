#integer related kernel functions
module Risc
  module Builtin
    module Integer
      module ClassMethods
        include AST::Sexp
        include CompileHelper

        def mod4 context
          compiler = compiler_for(:Integer,:mod4 ,{})
          return compiler.method
        end
        def putint context
          compiler = compiler_for(:Integer,:putint ,{})
          return compiler.method
        end

        def +( context )
          source = "plus"
          compiler = compiler_for(:Integer,:+ ,{other: :Integer})
          me , other = compiler.self_and_int_arg(source + "1")
          # reduce me and other to integers
          compiler.reduce_int( source + "2", me )
          compiler.reduce_int( source + "3", other )
          compiler.add_code Risc.op( source + "4", :+ , me , other)
          compiler.add_new_int(me , other)
          compiler.add_reg_to_slot( source + "5" , other , :message , :return_value)
          compiler.add_mom( Mom::ReturnSequence.new)
          return compiler.method
        end
        def div10( context )
          s = "div_10 "
          compiler = compiler_for(:Integer,:div10 ,{})
          me = compiler.add_known( :receiver )
          tmp = compiler.add_known( :receiver )
          q = compiler.add_known( :receiver )
          compiler.reduce_int( s , me )
          compiler.reduce_int( s , tmp )
          compiler.reduce_int( s , q )
          const = compiler.use_reg :fixnum , 1
          compiler.add_load_data( s , 1 , const )
          # int tmp = self >> 1
          compiler.add_code Risc.op( s , :>> , tmp , const)
          # int q = self >> 2
          compiler.add_load_data( s , 2 , const)
          compiler.add_code Risc.op( s , :>> , q , const)
          # q = q + tmp
          compiler.add_code Risc.op( s , :+ , q , tmp )
          # tmp = q >> 4
          compiler.add_load_data( s , 4 , const)
          compiler.add_transfer( s, q , tmp)
          compiler.add_code Risc.op( s , :>> , tmp , const)
          # q = q + tmp
          compiler.add_code Risc.op( s , :+ , q , tmp )
          # tmp = q >> 8
          compiler.add_load_data( s , 8 , const)
          compiler.add_transfer( s, q , tmp)
          compiler.add_code Risc.op( s , :>> , tmp , const)
          # q = q + tmp
          compiler.add_code Risc.op( s , :+ , q , tmp )
          # tmp = q >> 16
          compiler.add_load_data( s , 16 , const)
          compiler.add_transfer( s, q , tmp)
          compiler.add_code Risc.op( s , :>> , tmp , const)
          # q = q + tmp
          compiler.add_code Risc.op( s , :+ , q , tmp )
          # q = q >> 3
          compiler.add_load_data( s , 3 , const)
          compiler.add_code Risc.op( s , :>> , q , const)
          # tmp = q * 10
          compiler.add_load_data( s , 10 , const)
          compiler.add_transfer( s, q , tmp)
          compiler.add_code Risc.op( s , :* , tmp , const)
          # tmp = self - tmp
          compiler.add_code Risc.op( s , :- , me , tmp )
          compiler.add_transfer( s , me , tmp)
          # tmp = tmp + 6
          compiler.add_load_data( s , 6 , const)
          compiler.add_code Risc.op( s , :+ , tmp , const )
          # tmp = tmp >> 4
          compiler.add_load_data( s , 4 , const)
          compiler.add_code Risc.op( s , :>> , tmp , const )
          # return q + tmp
          compiler.add_code Risc.op( s , :+ , q , tmp )

          compiler.add_new_int(q , tmp)
          compiler.add_reg_to_slot( s , tmp , :message , :return_value)

          compiler.add_mom( Mom::ReturnSequence.new)
          return compiler.method
        end
      end
      extend ClassMethods
    end
  end
end
