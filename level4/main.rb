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

def validate_json(json_file)
  json = ImportData.new(json_file).perform
  schema = {
    "workers" => [{"id"=>1, "first_name"=>"Julie", "status"=>"medic"}],
    "shifts"  => [{"id"=>1, "planning_id"=>1, "user_id"=>1, "start_date"=>"2017-1-1"}]
  }
  JsonSchemaValidator.new(json,schema).perform
  DatesValidator.new(json["shifts"],"start_date").perform
  json
end

def create_json_output(json)
  workers = ObjectCreator.new(json["workers"],Worker).perform
  shifts = ObjectCreator.new(json["shifts"],Shift).perform
  night_shifts = NightShifts.new(workers,shifts)
  finance = Finance.new(night_shifts).perform
end

def run_program
  valid_json = validate_json("data/data.json")
  json_output = create_json_output(valid_json)
  File.open("data/night_shifts.json", 'w+'){ |json| json.write(JSON.pretty_generate(json_output))}
  puts "Night Shifts json successfully created" if File.exist?("data/night_shifts.json")
end

run_program
