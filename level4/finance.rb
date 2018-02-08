class Finance

  attr_reader :interim_fee
  attr_accessor :night_shifts, :fees

  def initialize(nightshifts)
    object_message = "should be an instance of NightShift"
    raise ArgumentError.new(object_message) unless nightshifts.is_a?(NightShifts)
    @night_shifts = nightshifts
    @interim_fee = 80
    @fees = @night_shifts.perform
  end

  def perform
    @fees["commission"] = { "pdg_fee": commission, "interim_shifts": interim_hours }
    @fees
  end

  def variable_pdg_fee
    @fees["workers"].sum { |array| array[:price] * 0.05 }
  end

  def commission
    interim_fees + variable_pdg_fee
  end

  def interim_fees
    interim_hours * @interim_fee
  end

  def interim_hours
    interims = @night_shifts.workers.select { |worker| worker.status == "interim" }
    interims.map! { |interim| interim.id }
    @night_shifts.shifts.count { |shift| interims.include?(shift.worker_id) }
  end

end
