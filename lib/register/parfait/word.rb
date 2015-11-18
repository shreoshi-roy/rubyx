

module Parfait
  # A word is a a short sequence of characters
  # Characters are not modeled as objects but as (small) integers
  # The small means two of them have to fit into a machine word, utf16 or similar
  #
  # Words are constant, maybe like js strings, ruby symbols
  # Words are short, but may have spaces

  # Words are objects, that means they carry Layout as index 0
  # So all indexes are offset by one in the implementation
  # Object length is measured in non-layout cells though

  class Word < Object
    attribute :char_length

    #semi "indexed" methods for interpreter
    def self.get_length_index
      2 # 2 is the amount of attributes, layout and char_length. the offset after which chars start
    end
    def self.get_indexed i
      i + get_length_index
    end
    # initialize with length. For now we try to keep all non-parfait (including String) out
    # String will contain spaces for non-zero length
    # Register provides methods to create Parfait objects from ruby
    def initialize len
      super()
      self.char_length = 0
      raise "Must init with int, not #{len.class}" unless len.kind_of? Fixnum
      raise "Must init with positive, not #{len}" if len < 0
      set_length( len , 32 ) unless len == 0 #32 beeing ascii space
      #puts "layout #{self.get_layout} #{self.object_id.to_s(16)}"
    end

    # return a copy of self
    def copy
      cop = Word.new( self.length )
      index = 1
      while( index <= self.length )
        cop.set_char(index , self.get_char(index))
        index = index + 1
      end
      cop
    end

    # return the number of characters
    def length()
      obj_len = self.char_length
      return obj_len
    end

    # make every char equal the given one
    def fill_with char
      fill_from_with(0 , char)
    end

    def fill_from_with from , char
      len = self.length()
      return if from <= 0
      while( from <= len)
        set_char( from , char)
        from = from + 1
      end
      from
    end

    # true if no characters
    def empty?
      return self.length == 0
    end

    # pad the string with the given character to the given length
    #
    def set_length(len , fill_char)
      return if len <= 0
      old = self.char_length
      return if old >= len
      self.char_length = len
      check_length
      fill_from_with( old + 1 , fill_char )
    end

    # set the character at the given index to the given character
    # character must be an integer, as is the index
    # the index starts at one, but may be negative to count from the end
    # indexes out of range will raise an error
    def set_char at , char
      raise "char not fixnum #{char.class}" unless char.kind_of? Fixnum
      index = range_correct_index(at)
      word_index = (index - 1) / 4 + 1 + Word.get_length_index
      rest = ((index - 1) % 4)
      shifted =  char << (rest * 8)
      was = get_internal( word_index )
      was = 0 unless was.is_a?(Numeric)
      mask = 0xFF << (rest * 8)
      mask = 0xFFFFFFFF - mask
      masked = was & mask
      put = masked + shifted
      set_internal( word_index , put )
      msg = "set index=#{index} word_index=#{word_index} rest=#{rest}= "
      msg += "char=#{char.to_s(16)} shifted=#{shifted.to_s(16)} "
      msg += "was=#{was.to_s(16)} masked=#{masked.to_s(16)} put=#{put.to_s(16)}"
      #puts msg
      char
    end

    # get the character at the given index (lowest 1)
    # the index starts at one, but may be negative to count from the end
    # indexes out of range will raise an error
    #the return "character" is an integer
    def get_char at
      index = range_correct_index(at)
      word_index = (index - 1 ) / 4 + 1 + Word.get_length_index
      rest = ((index - 1) % 4)
      char = get_internal(word_index)
      char = 0 unless char.is_a?(Numeric)
      shifted = char >> (8 * rest)
      ret = shifted & 0xFF
      msg = "get index=#{index} word_index=#{word_index} rest=#{rest}= "
      msg += " char=#{char.to_s(16)} shifted=#{shifted.to_s(16)}  ret=#{ret.to_s(16)}"
      #puts msg
      return ret
    end

    # private method to calculate negative indexes into positives
    def range_correct_index at
      index = at
      index = self.length + at if at < 0
      raise "index must be positive , not #{at}" if (index <= 0)
      raise "index too large #{at} > #{self.length}" if (index > self.length )
      return index
    end

    # compare the word to another
    # currently checks for same class, though really identity of the characters
    # in right order would suffice
    def == other
      return false if other.class != self.class
      return false if other.length != self.length
      len = self.length
      while(len > 0)
        return false if self.get_char(len) != other.get_char(len)
        len = len - 1
      end
      return true
    end

    def == other
      return false unless other.is_a?(String) or other.is_a?(Word)
      as_string = self.to_string
      unless other.is_a? String
        other = other.to_string
      end
      as_string == other
    end

    def to_string
      string = ""
      index = 1
      while( index <= self.char_length)
        char = get_char(index)
        string += char ? char.chr : "*"
        index = index + 1
      end
      string
    end

    # as we answered is_value? with true, sof will create a basic node with this string
    def to_sof
      "'" + to_s + "'"
    end

    def padded_length
      padded( 4 * get_layout().instance_length + self.char_length  )
    end

    private
    def check_length
      raise "Length out of bounds #{self.char_length}" if self.char_length > 1000
    end
  end

  # Word from string 
  def self.new_word( string )
    string = string.to_s if string.is_a? Symbol
    word = Parfait::Word.new( string.length )
    string.codepoints.each_with_index do |code , index |
      word.set_char(index + 1 , code)
    end
    word
  end

end