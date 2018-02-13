require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @worker = Worker.create(first_name: "Vladimir", status: "medic")
  end
  test "should get create" do
    get shifts_url
    assert_response :success
  end

  test "should get index" do
    get shifts_url
    assert_response :success
  end

  test "should create shift and get redirected to index" do
    assert_difference('Shift.count') do
      a =   post shifts_path, params: {
        shift: { start_date: "2018-05-13", worker_id: @worker.id }
      }
    end
    assert flash[:success]
    assert_redirected_to shifts_path
  end

  test "should fail to create shift and redirect to same page" do
    post shifts_path, params: {
      shift: { start_date: "vlan", worker_id: 1 }
    }
    assert flash[:shift_errors]
    assert_redirected_to shifts_path
  end

end
