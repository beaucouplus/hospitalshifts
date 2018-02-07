class ObjectCreator

  def initialize(array,object)
    @array = array
    @object = object
  end

  def perform
    @array.each_with_object([]) do |hash_, obj_array|
      properties = define_object_parameters(hash_)
      obj_array << @object.new(*properties)
    end
  end

  private

  def define_object_parameters(hash_)
    hash_.each_with_object([]) { |(k,property),properties| properties << property }
  end
end
