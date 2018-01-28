require "json"
require "pp"
require 'time'

# your code
file = File.read("data.json")
data = JSON.parse(file)
shifts = data["shifts"]
workers = data["workers"]
status = { medic: 270, interne: 126 }

def define_shift_fee(shifts,worker)
  worker_shifts = shifts.select { |shift| shift["user_id"] == worker["id"] }
  shift_fee = worker_shifts.count
  double_pay_shifts = worker_shifts.select do |shift|
    shift_time = Time.parse(shift["start_date"])
    shift_time.saturday? || shift_time.sunday?
  end.count
  shift_fee += double_pay_shifts
  pp shift_fee
end

night_shift = workers.each_with_object({"workers" => []}) do |worker, night_shift|
  shift_number = define_shift_fee(shifts,worker)
  total_price = shift_number * status[worker["status"].to_sym]
  night_shift["workers"] << { "id": worker["id"], "price": total_price }
end




# created a new json file in order to leave the example file.
File.open("night_shifts.json", 'w+'){ |file| file.write(night_shift.to_json)}
