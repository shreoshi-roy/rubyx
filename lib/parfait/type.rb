module Parfait

# An Object is conceptually a hash like structure. It is dynamic and
# you want to store values by name (instance variable names).
#
# One could (like mri), store the names in each object, but that is wasteful in both
# time and space (time for access, space to store implicitly known names ).
# Instead we store only the values, and access them by index (bit like c++).
# The Type allows the mapping of names to index.

# The Type of an object describes the memory layout of the object. In a c analogy,
# it is the information defined in a struct.
# The Type is a list of the names of instance variables, and their value types (int etc).
#
# Every object has a Type to describe it, so it's *first* instance variable is **always**
# "type". This means the name "type" is the first name in the list
# for every Type instance.

# But, as we want every Object to have a class, the Type carries that class.
# So the type of type has an entry "object_class", ir Type has an instance object_class.

# But Objects must also be able to carry methods themselves (ruby calls singleton_methods)
# and those too are stored in the Type. Those type instances are called singleton
# types, in analogy to the singleton classes they represent.
# In other words, "usually" a type represents a whole group of objects (instances of a
# class at the time the type was the instance_type). But for Singletons, ie objects
# that have a singleton class, the type is only for that object.

# An object is an "List" (memory location) of values of length n
# The Type is a list of n names and n types that describe the values stored in an
# actual object.
# Together they turn the object into a hash like structure

# For types to be a useful concept, they have to be unique and immutable. Any "change",
# like adding a name/type pair, will result in a new type instance.
# Type identity can be checked by the hash function, so two types are the same when their
# hashes are the same. The hash is made up of hashing all instance names and the class
# name.

# The Space class carries a hash of types of the systems, which is used to ensure that
# there is only one instance of every type. Hash and equality are defined on type
# for this to work.

  class Type < Object

    attr_reader :object_class , :names , :types , :methods

    def self.type_length
      6
    end

    # This is the default way to create  new type, because we add it to the
    # global list, to space.
    # The hash (actually the keys of the hash) and the object_class define the
    # identity of the type, which can be checked with the hash function.
    # single is by default 0, meaning you have to specify explicitly (1) for
    # it to be a "singleton" type (see class description)
    def self.for_hash( hash , object_class = :Object , single = 0)
      name = object_class
      if(object_class.is_a?(Symbol))
        object_class = Object.object_space.get_class_by_name(object_class)
      end
      raise "No such class #{name}" unless object_class
      hash = {type: object_class.name }.merge(hash) unless hash[:type]
      new_type = Type.new( object_class , hash , single)
      Object.object_space.add_type(new_type)
    end

    # should not be called directly. Use Type.for_hash instead, that adds the
    # type to the global list and does sym->class conversion if neccessary
    def initialize( object_class , hash , single )
      super()
      @is_single = single
      @object_class =  object_class
      @methods = nil
      @names = List.new
      @types = List.new
      raise "No type Type in #{hash}" unless hash[:type]
      private_add_instance_variable(:type , hash[:type]) #first
      hash.keys.each do |name |
        private_add_instance_variable(name , hash[name]) unless name == :type
      end
    end

    def is_single?
      @is_single == 1
    end

    def class_name
      @object_class&.name
    end

    def to_s
      str = "#{class_name}-["
      first = false
      @names.each do |name|
        unless(first)
          first = true
          str += ":#{name}"
        else
          str += ", :#{name}"
        end
      end
      str + "]"
    end

    def method_names
      names = List.new
      return names unless @methods
      @methods.each_method do |method|
        names.push method.name
      end
      names
    end

    def create_method( method_name , arguments , frame)
      raise "create_method #{method_name}.#{method_name.class}" unless method_name.is_a?(Symbol)
      #puts "Self: #{self.class} clazz: #{clazz.name}"
      raise "frame must be a type, not:#{frame}" unless frame.is_a?(Type)
      found = get_method( method_name )
      if found
        #puts "redefining method #{method_name}" #TODO, this surely must get more complicated
        raise "attempt to redifine method for different type " unless self == found.self_type
        found.init(arguments , frame)
        return found
      else
        add_method CallableMethod.new( method_name , self ,  arguments , frame )
      end
    end

    def add_method( method )
      raise "not a method #{method.class} #{method.inspect}" unless method.is_a? CallableMethod
      raise "syserr #{method.name.class}" unless method.name.is_a? Symbol
      if self.is_a?(Class) and (method.self_type != self)
        raise "Adding to wrong class, should be #{method.for_class}"
      end
      if get_method( method.name )
        remove_method(method.name)
      end
      method.set_next( @methods )
      @methods = method
      # puts "ADD method to #{self.inspect}:#{method.name}"
      method
    end

    def remove_method( method_name )
      raise "No such method #{method_name} in #{self.name}" unless @methods
      if( @methods.name == method_name)
        @methods = @methods.next_callable
        return true
      end
      method = @methods
      while(method && method.next_callable)
        if( method.next_callable.name == method_name)
          method.set_next( method.next_callable.next_callable )
          return true
        else
          method = method.next_callable
        end
      end
      raise "No such method #{method_name} in #{self.name}"
    end

    def get_method( fname )
      raise "get_method #{fname}.#{fname.class}" unless fname.is_a?(Symbol)
      return nil unless @methods
      @methods.each_method do |m|
        return m if(m.name == fname )
      end
      nil
    end

    def methods_length
      return 0 unless @methods
      len = 0
      @methods.each_method { len += 1}
      return len
    end

    def == other
      self.object_id == other.object_id
    end

    # add the name of an instance variable
    # Type objects are immutable, so a new object is returned
    # As types are also unique, two same adds will result in identical results
    def add_instance_variable( name , type )
      raise "No nil name" unless name
      raise "No nil type" unless type
      return self if @names.index_of(name)
      hash = to_hash
      hash[name] = type
      return Type.for_hash( hash , object_class)
    end

    def instance_length
      @names.get_length()
    end

    # index of the variable when using get_internal_word
    # (get_internal_word is 0 based and 0 is always the type)
    def variable_index( name )
      has = @names.index_of(name)
      return nil unless has
      raise "internal error #{name}:#{has}" if has < 0
      has
    end

    def get_length()
      @names.get_length()
    end

    def name_at( index )
      raise "No names #{index}" unless @names
      @names.get(index)
    end

    def type_at( index )
      @types.get(index)
    end

    def type_for( name )
      index = variable_index(name)
      return nil unless index
      type_at(index)
    end

    def inspect
      "Type[#{@names.inspect}]"
    end

    def rxf_reference_name
      "#{@object_class.name}_Type"
    end
    alias :name :rxf_reference_name

    def each
      index = 0
      while( index <  get_length() )
        yield( name_at(index) , type_at(index) )
        index += 1
      end
    end

    def each_method(&block)
      return unless @methods
      @methods.each_method(&block)
    end

    def to_hash
      hash = {}
      each do |name , type|
        raise "Name nil #{type}" unless name
        raise "Type nil #{name}" unless type
        hash[name] = type
      end
      hash
    end

    def hash
      index = 1
      name = object_class.is_a?(Symbol) ? object_class : object_class.name
      hash_code = Type.str_hash(name)
      each do |name , type|
        item_hash = Type.str_hash(name) + Type.str_hash(type)
        hash_code  += item_hash + (item_hash / 256 ) * index
        index += 1
      end
      hash_code % (2 ** 62)
    end

    def self.str_hash(str)
      if RUBY_ENGINE == 'opal'
        hash = 5381
        str.to_s.each_char do |c|
          hash = ((hash << 5) + hash) + c.to_i; # hash * 33 + c  without getting bignums
        end
        hash % (2 ** 51)
      else
        str.hash
      end
    end

    private

    def private_add_instance_variable( name , type)
      raise "Name shouldn't be nil" unless name
      raise "Value Type shouldn't be nil" unless type
      @names.push(name)
      @types.push(type)
    end

  end
end
