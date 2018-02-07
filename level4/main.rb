require "json"
require "pp"
require 'time'
require_relative 'finance'
require_relative 'night_shifts'
require_relative 'shift'
require_relative 'utils/dates_validator'
require_relative 'utils/import_data'
require_relative 'utils/json_schema_validator'
require_relative 'utils/object_creator'
require_relative 'worker'

json = ImportData.new("data/data.json").perform

schema = {
  "workers" => [{"id"=>1, "first_name"=>"Julie", "status"=>"medic"}],
  "shifts"  => [{"id"=>1, "planning_id"=>1, "user_id"=>1, "start_date"=>"2017-1-1"}]
}

JsonSchemaValidator.new(json,schema).perform
DatesValidator.new(json["shifts"],"start_date").perform

workers = ObjectCreator.new(json["workers"],Worker).perform
shifts = ObjectCreator.new(json["shifts"],Shift).perform

night_shifts = NightShifts.new(workers,shifts)
finance = Finance.new(night_shifts)
File.open("night_shifts.json", 'w+'){ |json| json.write(JSON.pretty_generate(finance.perform))}
