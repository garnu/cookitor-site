SecureMarshal.configure do |config|
  config.allow_symbol_creation = false # symbols are not garbage collected it's recommended not to allow the creation of new symbols as it can fill the memory
  convert_symbol_to_string = true
end