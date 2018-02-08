class Worker
  attr_accessor :first_name, :status
  attr_reader :id, :price, :shifts

  @@price_per_status = { medic: 270, interne: 126, interim: 480 }
  def initialize(id, first_name, status)
    message = "Wrong type, parameter classes should be Int, String, String"
    raise ArgumentError.new(message) unless id.is_a?(Integer) && first_name.is_a?(String) && status.is_a?(String)
    @id = id
    @first_name = first_name
    @status = status
    @price = @@price_per_status[status.to_sym]
  end

  def add_shifts(shifts = @shifts)
    @shifts = shifts.select { |shift| shift.worker_id == self.id }
  end

  def shifts
    @shifts
  end

  def count_shifts
    @shifts.count
  end

  def count_extra_hours
    @shifts.select{ |shift| shift.week_end? }.count
  end

  def pay
    (count_shifts + count_extra_hours) * @price
  end
end
