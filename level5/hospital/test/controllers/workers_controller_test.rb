require 'test_helper'

class WorkersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get workers_new_url
    assert_response :success
  end

  test "should get create" do
    get workers_create_url
    assert_response :success
  end

  test "should get index" do
    get workers_index_url
    assert_response :success
  end

  test "should get edit" do
    get workers_edit_url
    assert_response :success
  end

  test "should get update" do
    get workers_update_url
    assert_response :success
  end

end
