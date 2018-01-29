require "json"
require "pp"
require 'time'

class Hospital_shifts

  def initialize
    file = File.read("data.json")
    data = JSON.parse(file)
    @shifts = data["shifts"]
    @workers = data["workers"]
    @status = { medic: 270, interne: 126, interim: 480 }
  end

  def perform
    @night_shift = calculate_night_shift_prices
    define_commission
    create_json
  end

  private

  def calculate_night_shift_prices
    @workers.each_with_object({"workers" => []}) do |worker, shift|
      shift_number = define_shift_number(worker)
      total_price = shift_number * @status[worker["status"].to_sym]
      shift["workers"] << { "id": worker["id"], "price": total_price }
    end
  end

  def define_commission
    interim_fee = define_interim_hours * 80
    variable_pdg_fee = @night_shift["workers"].sum { |array| array[:price] * 0.05 }
    pdg_fee = interim_fee + variable_pdg_fee
    @night_shift["commission"] = { "pdg_fee": pdg_fee, "interim": define_interim_hours }
  end

  def define_interim_hours
    interims =  @workers.select { |worker| worker["status"] == "interim" }
    interims.map! { |interim| interim["id"] }
    @shifts.count { |shift| interims.include?(shift["user_id"])  }
  end

  def define_shift_number(worker)
    worker_shifts = @shifts.select { |shift| shift["user_id"] == worker["id"] }
    shift_number = worker_shifts.count
    double_pay_shifts = worker_shifts.select do |shift|
      shift_time = Time.parse(shift["start_date"])
      shift_time.saturday? || shift_time.sunday?
    end.count
    shift_number += double_pay_shifts
  end

  def create_json
    File.open("night_shifts.json", 'w+'){ |json| json.write(@night_shift.to_json)}
  end

end


Hospital_shifts.new.perform
