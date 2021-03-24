require 'test_helper'

class EmandateSiControllerTest < ActionDispatch::IntegrationTest
  test "should get mandate_verification_handler" do
    get emandate_si_mandate_verification_handler_url
    assert_response :success
  end

end
