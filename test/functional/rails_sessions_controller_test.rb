require 'test_helper'

class RailsSessionsControllerTest < ActionController::TestCase
  test "should get decode" do
    get :decode
    assert_response :success
  end

  test "should get encode" do
    get :encode
    assert_response :success
  end

end
