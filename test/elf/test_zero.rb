require_relative "helper"

module Elf

  class TestZeroCode < FullTest

    def setup
      super
      @linker = RubyX::RubyXCompiler.new(RubyX.default_test_options).ruby_to_binary(as_main("return 1"),:arm)
    end

    def test_empty_translate
      writer = Elf::ObjectWriter.new(@linker )
      writer.save StringIO.new
    end

    def test_empty_translate_with_debug
      writer = Elf::ObjectWriter.new(@linker , debug: true )
      writer.save StringIO.new
    end
  end
end
