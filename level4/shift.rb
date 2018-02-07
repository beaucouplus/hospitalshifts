class Shift
  attr_reader :id, :planning_id, :worker_id
  attr_accessor :start_date
  def initialize(id,planning_id,worker_id,start_date)
    @id = id
    @planning_id = planning_id
    @worker_id = worker_id
    @start_date = Time.parse(start_date)
  end

  def week_end?
    @start_date.saturday? || @start_date.sunday?
  end


end
