class NightShifts

  attr_reader :workers, :shifts

  def initialize(workers,shifts)
    type_message = "Arguments should be arrays"
    raise ArgumentError.new(type_message) unless workers.is_a?(Array) && shifts.is_a?(Array)
    empty_message = "Arrays are empty"
    raise ArgumentError.new(empty_message) if workers.empty? || shifts.empty?
    @workers = workers
    @shifts = shifts
  end

  def perform
    @workers.each_with_object({"workers" => []}) do |worker, shift|
      worker.add_shifts(@shifts)
      shift["workers"] << { "id": worker.id, "price": worker.pay }
    end
  end

end
