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
    assert DatesValidator.new(@data["shifts"],"start_date").perform
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
  end

  def test_should_accept_only_specified_parameters_classes
    error = assert_raises ArgumentError do
      Worker.new("3",1,1)
    end
    assert_equal error.message, "Wrong type, parameter classes should be Int, String, String"
  end

  def test_price_should_be_linked_to_status
    assert_equal 270, Worker.new(1,"Bernard","medic").price
  end

  def test_should_be_able_to_link_shifts
    worker = Worker.new(1,"Bernard","medic")
    pp worker.add_shifts(@shifts)
    assert_kind_of Array, worker.shifts
    assert_instance_of Shift, worker.shifts[0]
  end

end
