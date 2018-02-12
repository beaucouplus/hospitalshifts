require 'test_helper'

class WorkersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @worker = Worker.create(first_name: "Vladimir", status: "medic")
  end

  test "should get create" do
    get workers_url
    assert_response :success
  end

  test "should get index" do
    get workers_url
    assert_response :success
  end

  test "should get edit" do
    get edit_worker_path(@worker)
    assert_response :success
  end

  test "should get update" do
    get workers_url
    assert_response :success
  end

  test "should create worker and get redirected to index" do
    assert_difference('Worker.count') do
      post workers_path, params: {
        worker: { first_name: "Gérard", status: "medic" }
      }
    end
    assert_redirected_to workers_path
  end

  test "should fail to create reservation and redirect to same page or root path" do
    post workers_path, params: {
      worker: { first_name: "Gérard", status: "plumber" }
    }
    assert_redirected_to root_path
  end

  test "should edit worker and get redirected to index" do
    new_first_name = "Francis"
    new_status = "interne"
    put worker_path(@worker), params: {
      worker: { id: @worker.id, first_name: new_first_name, status: new_status }
    }
    worker = Worker.find(@worker.id)
    assert_equal new_first_name, worker.first_name
    assert_equal new_status, worker.status
    assert_redirected_to workers_path
  end

  test "should fail to edit worker and rerender edit" do
    put worker_path(@worker), params: {
      worker: { id: @worker.id, first_name: nil, status: "medic" }
    }
    assert_response 200
    assert_includes @response.body, "Edit worker"
    assert_includes @response.body, @worker.status
  end


end
