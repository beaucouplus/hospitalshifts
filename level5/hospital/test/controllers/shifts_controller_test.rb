require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest

  test "should get create" do
    get shifts_url
    assert_response :success
  end

  test "should get index" do
    get shifts_url
    assert_response :success
  end

end
