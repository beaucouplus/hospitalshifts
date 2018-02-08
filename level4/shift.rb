class Shift
  attr_reader :id, :planning_id, :worker_id
  attr_accessor :start_date
  def initialize(id,planning_id,worker_id,start_date)
    message = "Wrong type, parameter classes should be Int, Int, Int, Date"
    raise ArgumentError.new(message) unless id.is_a?(Integer) && planning_id.is_a?(Integer) && worker_id.is_a?(Integer)
    @id = id
    @planning_id = planning_id
    @worker_id = worker_id
    begin
      @start_date = Time.parse(start_date)
    rescue => e
      raise ArgumentError.new("Incorrect date format")
    end;

  end

  def week_end?
    @start_date.saturday? || @start_date.sunday?
  end


end
