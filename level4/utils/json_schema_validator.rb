class JsonSchemaValidator
  def initialize(json,json_schema)
    hash_message = "Should be a Hash"
    raise ArgumentError.new(hash_message) unless json.is_a?(Hash) && json_schema.is_a?(Hash)
    nil_message = "Your json is empty."
    raise ArgumentError.new(nil_message) if json.empty? || json_schema.empty?

    @json = json
    @json_schema = json_schema
  end

  def perform
    json_schema = remove_array_from_json(@json_schema)
    @json.each do |key,v|
      check_for_errors_in_classes(key,json_schema)
    end;
    true
  end

  private

  def remove_array_from_json(json)
    json.each_with_object({}) do |(key,value),keys_hash|
      return if json[key].is_a? Hash
      json[key].map do |json_hash|
        keys_hash[key.to_sym] = json_hash
    end; end;
  end

  def check_for_errors_in_classes(key,json_schema)
    valid_keys = json_schema.dig(key.to_sym).keys
    valid_classes = json_schema.dig(key.to_sym).values.map(&:class)
    @json[key].each_with_index do |json_hash,i|
      wrong_class = "Your json schema seems invalid: "
      wrong_class << "Check item ##{i + 1} in #{key} database"
      if json_hash.keys != valid_keys || json_hash.values.map(&:class) != valid_classes
        raise ArgumentError.new(wrong_class)
    end; end;
  end

end
