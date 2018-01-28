require "json"
require "pp"

# your code
file = File.read("data.json")
data = JSON.parse(file)
shifts = data["shifts"]
workers = data["workers"]

night_shift = workers.each_with_object({"workers" => []}) do |worker, night_shift|
  shift_number = shifts.count { |shift| shift["user_id"] == worker["id"] }
  total_price = shift_number * worker["price_per_shift"]
  night_shift["workers"] << { "id": worker["id"], "price": total_price }
end

# created a new json file in order to leave the example file.
File.open("night_shifts.json", 'w+'){ |file| file.write(night_shift.to_json)}
