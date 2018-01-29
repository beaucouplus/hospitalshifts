require "json"
require "pp"

# your code
file = File.read("data.json")
data = JSON.parse(file)
shifts = data["shifts"]
workers = data["workers"]
status = { medic: 270, interne: 126 }

night_shift = workers.each_with_object({"workers" => []}) do |worker, shift_hash|
  shift_number = shifts.count { |shift| shift["user_id"] == worker["id"] }
  total_price = shift_number * status[worker["status"].to_sym]
  shift_hash["workers"] << { "id": worker["id"], "price": total_price }
end

# created a new json file in order to leave the example file.
File.open("night_shifts.json", 'w+'){ |json| json.write(night_shift.to_json)}
