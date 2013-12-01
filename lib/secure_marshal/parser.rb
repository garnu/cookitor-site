module SecureMarshal
  class Parser
    MAJOR_VERSION = "\x04"
    MINOR_VERSION = "\x08"

    def initialize(content)
      @tainted = content.tainted?
      @content = content.to_s
      @symbols = []
      raise "Unrecognised Marshal format version (4.8 supported)" unless supported_version?
      @content = @content.byteslice(2, @content.length-2) # strip the version
    end

    def parse
      puts @content.inspect
      type = @content.byteslice(0)
      @content = @content.byteslice(1, @content.length-1)
      case type
      when '0'
        raise "Nil type parsing is not allowed" unless type_allowed? :nil
        result = nil
      when 'T'
        raise "Boolean type parsing is not allowed" unless type_allowed? :boolean
        result = true
      when 'F'
        raise "Boolean type parsing is not allowed" unless type_allowed? :boolean
        result = false
      when 'i'
        raise "Integer type parsing is not allowed" unless type_allowed? :integer
        result = parse_integer
      when 'f'
        raise "Float type parsing is not allowed" unless type_allowed? :float
        result = parse_float
      when '['
        raise "Array parsing is not allowed" unless type_allowed? :array
        result = parse_array
      when '{'
        raise "Hash parsing is not allowed" unless type_allowed? :hash
        result = parse_hash
      when '"'
        raise "String parsing is not allowed" unless type_allowed? :string
        result = parse_string
      when ':'
        raise "Symbol parsing is not allowed" unless type_allowed? :symbol
        result = parse_symbol
      when ';'
        raise "Marshal reference parsing is not allowed" unless type_allowed? :reference
        result = parse_reference
      when 'I'
        raise "Instance parsing is not allowed" unless type_allowed? :instance
        result = parse_instance
      else
        raise "The Marshal dump contains unsupported type"
      end
      result = result.taint if @tainted
      
      result
    end

    def self.load(content)
      sm = SecureMarshal::Parser.new(content)
      sm.parse
    end

    private

    def supported_version?
      @content[0] == MAJOR_VERSION && @content[1] == MINOR_VERSION
    end

    def type_allowed?(type)
      SecureMarshal.configuration.allowed_types.include?(type.to_sym)
    end

    def parse_integer
      first_byte = @content.getbyte(0)
      length = 0
      if first_byte.to_i == 0 # zero
        result = 0
      elsif first_byte > 5 && first_byte < 251 # integer on byte
        result = first_byte - ((first_byte > 127)? 251 : 5)
      else
        result = Marshal.load(MAJOR_VERSION+MINOR_VERSION+'i'+@content) # use native Marshal for parsing integers as it should be quick and safe
        length = (first_byte < 5)? first_byte : 1
      end
      length += 1
      @content = @content.byteslice(length, @content.length - length)

      result
    end

    def parse_float
      Float(parse_string)
    end

    def parse_array
      length = parse_integer
      result = Array.new
      length.times do
        result << parse
      end
      
      result
    end

    def parse_hash
      length = parse_integer
      result = Hash.new
      length.times do
        key = parse
        value = parse
        result[key] = value
      end

      result
    end

    def parse_string
      result = Marshal.load(MAJOR_VERSION+MINOR_VERSION+'"'+@content) # use native Marshal for parsing basic string as it should be quick and safe
      length = parse_integer
      @content = @content.byteslice(length, @content.length - length)

      result
    end

    def parse_symbol
      result = parse_string
      @symbols << result # add it to the symbol table for reference
      result = result.to_sym unless SecureMarshal.configuration.convert_symbol_to_string
      
      result
    end

    def parse_reference
      index = parse_integer
      result = @symbols[index]
      
      result
    end

    def parse_instance
      result = parse # object data
      instance_variables = parse_integer
      instance_variables.times do
        type = @content.byteslice(0)
        if type == ':'
          @content = @content.byteslice(1, @content.length-1) # remove ':'
          instance_variable = parse_symbol 
        elsif type == ';' # reference
          @content = @content.byteslice(1, @content.length-1) # remove ';'
          instance_variable = parse_reference
        else
          raise "Symbol or reference expected for instance variable" unless @content.byteslice(0) == ':'
        end
        instance_value = parse
        if instance_variable.to_s == "E"
          encoding = (instance_value)? 'UTF-8' : 'US-ASCII'
          result.force_encoding(encoding)
        elsif instance_variable.to_s == "encoding"
          result.force_encoding(instance_value)
        else
          if Symbol.all_symbols.any? { |sym| sym.to_s == instance_variable } || SecureMarshal.configuration.allow_symbol_creation
            result.tap {|i| i.instance_variable_set(instance_variable, instance_value)}
          else
            raise "Symbol creation is now allowed"
          end
        end
      end
      
      result
    end
  end
end
