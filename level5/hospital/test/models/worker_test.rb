require 'test_helper'

class WorkerTest < ActiveSupport::TestCase
  setup do
    @worker = Worker.create(first_name: "Vladimir", status: "medic")
  end

  test "empty worker should be invalid" do
    worker = Worker.new
    refute worker.valid?
  end

  test "worker should be valid with all parameters" do
    assert @worker.valid?
  end

  test "worker should be invalid without first_name" do
    @worker.first_name = nil
    refute @worker.valid?
  end

  test "worker should be invalid without status" do
    @worker.status = nil
    refute @worker.valid?
  end

  test "worker should be invalid if status is not included in the status list" do
    @worker.status = "pikachu"
    refute @worker.valid?
  end

  test "2 workers should not have the same first_name" do
    worker_1 = Worker.create(first_name: "Paolo", status: "medic")
    @worker.first_name = "Paolo"
    refute @worker.valid?
  end
end
