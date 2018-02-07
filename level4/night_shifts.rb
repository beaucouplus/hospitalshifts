class NightShifts

  attr_reader :workers, :shifts

  def initialize(workers,shifts)
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
