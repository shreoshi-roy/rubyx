require_relative "../helper"

module Risc
  class TestCollector < MiniTest::Test

    def setup
      @machine = Risc.machine.boot
    end

    def test_simple_collect
      objects = Risc::Collector.collect_space
      assert ((350 < objects.length) or (430 > objects.length)) , objects.length.to_s
    end

    def test_collect_all_types
      objects = Risc::Collector.collect_space
      objects.each do |id, objekt|
        next unless objekt.is_a?( Parfait::Type )
        assert Parfait.object_space.get_type_for( objekt.hash ) , objekt.hash
      end
    end

  end
end
