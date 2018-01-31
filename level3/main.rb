require "json"
require "pp"
require 'time'

# your code
file = File.read("data.json")
data = JSON.parse(file)
shifts = data["shifts"]
workers = data["workers"]
status = { medic: 270, interne: 126 }

def define_shift_number(shifts,worker)
  worker_shifts = shifts.select { |shift| shift["user_id"] == worker["id"] }
  shift_number = worker_shifts.count
  double_pay_shifts = worker_shifts.select do |shift|
    shift_time = Time.parse(shift["start_date"])
    shift_time.saturday? || shift_time.sunday?
  end.count
  shift_number += double_pay_shifts
end

night_shift = workers.each_with_object({"workers" => []}) do |worker, shift|
  shift_number = define_shift_number(shifts,worker)
  total_price = shift_number * status[worker["status"].to_sym]
  shift["workers"] << { "id": worker["id"], "price": total_price }
end




# created a new json file in order to leave the example file.
File.open("night_shifts.json", 'w+'){ |json| json.write(JSON.pretty_generate(@night_shift))}
