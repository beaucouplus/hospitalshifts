require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  setup do
    @worker = Worker.create(first_name: "Vladimir", status: "medic")
    @shift = Shift.new(worker_id: @worker.id,start_date: "2018-01-18")
  end

  test "empty shift should be invalid" do
    shift = Shift.new
    refute shift.valid?
  end

  test "shift should be valid with all parameters" do
    assert @shift.valid?
  end

  test "shift should be invalid without worker_id" do
    @shift.worker_id = nil
    refute @shift.valid?
  end

  test "shift should be invalid without start_date" do
    @shift.start_date = nil
    refute @shift.valid?
  end

  test "shift should be invalid if start_date is an invalid date" do
    @shift.start_date = "boom"
    refute @shift.valid?
  end

  test "2 shifts should not be able to happen on the same day" do
    shift_1 = Shift.create(worker_id: @worker.id, start_date: "2018-02-18")
    @shift.start_date = "2018-02-18"
    refute @shift.valid?
  end

end
