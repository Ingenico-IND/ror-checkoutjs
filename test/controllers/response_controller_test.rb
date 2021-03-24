require 'test_helper'

class ResponseControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get response_home_url
    assert_response :success
  end

end
