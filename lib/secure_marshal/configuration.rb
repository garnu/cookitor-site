module SecureMarshal
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?

    configuration
  end

  class Configuration
    attr_accessor :allowed_types, :allow_symbol_creation, :convert_symbol_to_string

    def initialize
      @allowed_types = [:nil, :boolean, :integer, :float, :array, :hash, :string, :symbol, :reference, :instance]
      @allow_symbol_creation = false
      @convert_symbol_to_string = true
    end
  end
end