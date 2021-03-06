require_relative "helper"

module Parfait
  class TestAttributes < ParfaitTest

    def setup
      super
      @mess = @space.get_next_for(:Message)
      @type = @mess.get_type
    end

    def test_message_get_type
      assert_equal Parfait::Type , @type.class
    end

    def test_message_name_nil
      last = @type.names.last
      assert_equal :local15 , last , @type.names.inspect
      assert_nil  @mess.method
    end
    def test_message_next_set
      @mess._set_next_message :next_message
      assert_equal :next_message , @mess.next_message
    end
    def test_message_type_set
      @mess.set_type @type
      assert_equal @type , @mess.get_type
    end
    def test_attribute_index
      @mess._set_next_message  :message
      assert_equal Parfait::Type , @mess.get_type.class
    end

    def test_type_type
      assert_equal Parfait::Type , @type.get_type.get_type.class
    end
    def test_type_type_type
      assert_equal Parfait::Type , @type.get_type.get_type.get_type.class
    end
  end
end
