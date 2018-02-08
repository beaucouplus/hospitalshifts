require 'minitest/autorun'
require_relative 'main'

class ImportDataTest < Minitest::Test
  def test_function_import_data_should_raise_error_when_no_data
    error = assert_raises ArgumentError do
      ImportData.new(nil).perform
    end
    assert_equal error.message, "No data loaded, don't forget to load a file"
  end

  def test_function_import_should_return_a_hash
    assert_kind_of Hash,  ImportData.new("data/data.json").perform
  end
end

class JsonSchemaValidatorTest < Minitest::Test
  def setup
    @data = { "workers" => [{ "id"=> 1, "first_name"=> "Léonore", "status"=> "medic" },
                            { "id"=> 2, "first_name"=> "Julien", "status"=> "medic" }],
              "shifts" => [{ "id"=> 1, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-1" },
                           { "id"=> 2, "planning_id"=> 1, "user_id"=> 2, "start_date"=> "2017-1-2" }]
              }
    @schema = {
      "workers" => [{"id"=>1, "first_name"=>"Julie", "status"=>"medic"}],
      "shifts"  => [{"id"=>1, "planning_id"=>1, "user_id"=>1, "start_date"=>"2017-1-1"}]
    }
  end

  def test_should_raise_error_when_json_empty
    @data = {}
    error = assert_raises ArgumentError do
      JsonSchemaValidator.new(@data,@schema)
    end
    assert_equal error.message, 'Your json is empty.'
  end

  def test_should_raise_error_when_not_hash
    @data = []
    error = assert_raises ArgumentError do
      JsonSchemaValidator.new(@data,@schema)
    end
    assert_equal error.message, 'Should be a Hash'
  end

  def test_should_raise_error_when_wrong_data_type
    @data["workers"][0]["first_name"] = 1
    error = assert_raises ArgumentError do
      JsonSchemaValidator.new(@data,@schema).perform
    end
    assert_equal error.message, 'Your json schema seems invalid: Check item #1 in workers database'
  end

  def test_should_be_true_if_everything_ok
    assert JsonSchemaValidator.new(@data,@schema).perform
  end

end

class DatesValidatorTest < Minitest::Test
  def setup
    @data = { "workers" => [{ "id"=> 1, "first_name"=> "Léonore", "status"=> "medic" },
                            { "id"=> 2, "first_name"=> "Julien", "status"=> "medic" }],
              "shifts" => [{ "id"=> 1, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-1" },
                           { "id"=> 2, "planning_id"=> 1, "user_id"=> 2, "start_date"=> "2017-1-2" }]
              }
  end

  def test_should_raise_error_when_wrong_data_type
    error = assert_raises ArgumentError do
      DatesValidator.new("string",1)
    end
    assert_equal error.message, 'Arguments should be an array and Hash Key (string)'
  end

  def test_should_raise_error_when_wrong_date
    @data["shifts"][0]["start_date"] = "2017-1-32"
    error = assert_raises ArgumentError do
      DatesValidator.new(@data["shifts"],"start_date").perform
    end
    assert_equal error.message, 'Incorrect date : 2017-1-32'
  end

  def test_should_raise_error_when_overlapping
    @data["shifts"][0]["start_date"] = "2017-1-1"
    @data["shifts"][1]["start_date"] = "2017-1-1"
    error = assert_raises ArgumentError do
      DatesValidator.new(@data["shifts"],"start_date").perform
    end
    assert_equal error.message, 'Detected overlapping : 2 events cannot happen the same day.'
  end

  def test_should_be_true_if_everything_ok
    assert_equal true, DatesValidator.new(@data["shifts"],"start_date").perform
  end
end




class ObjectCreatorTest < Minitest::Test
  def setup
    @data =  [{ "id"=> 1, "first_name"=> "Léonore", "status"=> "medic" },
              { "id"=> 2, "first_name"=> "Julien", "status"=> "medic" }]
  end

  def test_should_return_an_array
    assert assert_kind_of Array, ObjectCreator.new(@data,Worker).perform
  end

  def test_array_should_be_populated_with_objects
    assert assert_instance_of Worker, ObjectCreator.new(@data,Worker).perform[0]
  end

  def test_should_work_with_any_array_of_hashes__and_objects_couple
    @data =  [{ "color"=> "black", "type"=> "porsche", "year"=> "1983" },
              { "color"=> "red", "type"=> "renault", "year"=> "1985" }]
    assert_instance_of Car, ObjectCreator.new(@data,Car).perform[0]
    assert_equal "black", ObjectCreator.new(@data,Car).perform[0].color
    assert_equal "renault", ObjectCreator.new(@data,Car).perform[1].type
  end
end

#random class to test ObjectCreator
class Car
  attr_reader :color, :type, :year
  def initialize(color,type,year)
    @color = color
    @type = type
    @year = year
  end;
end


class WorkerTest < Minitest::Test
  def setup
    shifts_data = [{ "id"=> 1, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-1" },
                   { "id"=> 2, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-2" }]
    @shifts = ObjectCreator.new(shifts_data,Shift).perform
    @worker = Worker.new(1,"Bernard","medic")
    @worker.add_shifts(@shifts)
  end

  def test_should_accept_only_specified_parameters_classes
    error = assert_raises ArgumentError do
      Worker.new("3",1,1)
    end
    assert_equal error.message, "Wrong type, parameter classes should be Int, String, String"
  end

  def test_price_should_be_linked_to_status
    assert_equal 270, @worker.price
  end

  def test_should_be_able_to_link_shifts
    assert_kind_of Array, @worker.shifts
    assert_instance_of Shift, @worker.shifts[0]
  end

  def test_should_count_shifts
    assert_equal 2, @worker.count_shifts
  end

  def test_should_count_extra_hours
    assert_equal 1, @worker.count_extra_hours
  end

  def test_should_define_pay
    assert_equal 810, @worker.pay
  end

end

class ShiftTest < Minitest::Test

  def test_should_accept_only_specified_parameters_classes
    error = assert_raises ArgumentError do
      Shift.new(1,"1",1,"2018-3-17")
    end
    assert_equal error.message, "Wrong type, parameter classes should be Int, Int, Int, Date"
  end

  def test_should_raise_error_when_wrong_date_format
    error = assert_raises ArgumentError do
      Shift.new(1,1,1,"2018-3-32")
    end
    assert_equal error.message, "Incorrect date format"
  end

  def test_should_return_true_when_week_end
    assert_equal true, Shift.new(1,1,1,"2018-3-4").week_end?
  end

  def test_should_return_false_when_outside_week_end
    assert_equal false, Shift.new(1,1,1,"2018-3-6").week_end?
  end

end

class NightShiftsTests < Minitest::Test
  def setup
    workers_data = [{ "id"=> 1, "first_name"=> "Léonore", "status"=> "medic" },
                    { "id"=> 2, "first_name"=> "Julien", "status"=> "medic" } ]
    @workers = ObjectCreator.new(workers_data,Worker).perform
    shifts_data = [{ "id"=> 1, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-1" },
                   { "id"=> 2, "planning_id"=> 1, "user_id"=> 2, "start_date"=> "2017-1-2" }]
    @shifts = ObjectCreator.new(shifts_data,Shift).perform
  end

  def test_should_accept_only_specified_parameters_classes
    error = assert_raises ArgumentError do
      NightShifts.new([],{})
    end
    assert_equal error.message, "Arguments should be arrays"
  end

  def test_should_raise_error_when_empty_arrays
    error = assert_raises ArgumentError do
      NightShifts.new([],[{}])
    end
    assert_equal error.message, "Arrays are empty"
  end

  def test_should_return_a_hash
    assert_kind_of Hash, NightShifts.new(@workers,@shifts).perform
  end

  def test_hash_should_contain_these_values
    result = {"workers"=>[{:id=>1, :price=>540}, {:id=>2, :price=>270}]}
    assert_equal result, NightShifts.new(@workers,@shifts).perform
  end

end

class FinanceTests < Minitest::Test
  def setup
    workers_data = [{ "id"=> 1, "first_name"=> "Léonore", "status"=> "medic" },
                    { "id"=> 2, "first_name"=> "Julien", "status"=> "interim" } ]
    @workers = ObjectCreator.new(workers_data,Worker).perform
    shifts_data = [{ "id"=> 1, "planning_id"=> 1, "user_id"=> 1, "start_date"=> "2017-1-1" },
                   { "id"=> 2, "planning_id"=> 1, "user_id"=> 2, "start_date"=> "2017-1-2" }]
    @shifts = ObjectCreator.new(shifts_data,Shift).perform
    @nightshifts = NightShifts.new(@workers,@shifts)
    @finance = Finance.new(NightShifts.new(@workers,@shifts))
  end

  def test_argument_should_be_a_hash
    error = assert_raises ArgumentError do
      Finance.new([])
    end
    assert_equal error.message, "should be an instance of NightShift"
  end

  def test_interim_hours_should_count_interim_hours
    assert_equal 1, @finance.interim_hours
  end

  def test_interim_fees_should_multiply_interim_hours_by_interim_fee
    assert_equal 80, @finance.interim_fees
  end

  def test_interim_fees_should_multiply_interim_hours_by_interim_fee
    assert_equal 80, @finance.interim_fees
  end

  def test_variable_pdg_fee_should_calculate_each_worker_price_by_5_per_cent
    assert_equal 51, @finance.variable_pdg_fee
  end

  def test_commission_should_add_interim_fees_with_variable_pdg_fee
    assert_equal 131, @finance.commission
  end

  def test_perform_should_append_to_nightshift_json
    assert_equal ["workers","commission"], @finance.perform.keys
  end

  def test_perform_should_mention_pdg_fee_and_interim_hours
    result = {:pdg_fee=>131.0, :interim_shifts=>1}
    finance = @finance.perform
    assert_equal result, finance["commission"]
  end

end

class MainFunctionsTest < Minitest::Test

  def setup
    @valid_json = validate_json("data/data.json")
    @json_output = create_json_output(@valid_json)
    @night_shifts_json = "data/night_shifts.json"
    @example_json = "data/output.json"
  end

  def test_validate_json_should_return_a_hash
    assert_kind_of Hash, @valid_json
  end

  def test_create_json_output_should_return_a_hash
    assert_kind_of Hash, @json_output
  end

  def test_create_json_output_hash_should_contain_these_keys
    assert_equal ["workers","commission"], @json_output.keys
  end

  def test_run_program_should_create_night_shifts_json
    assert File.exist?("data/night_shifts.json"), run_program
  end

  def test_output_json_and_night_shifts_json_should_be_equivalent
    assert true, File.identical?(@night_shifts_json, @example_json)
  end
end
