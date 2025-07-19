require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get dashboard_url
    assert_response :redirect
  end

  test "should get login" do
    get login_url
    assert_response :success
  end

  test "should get logout when logged in" do
    delete logout_url
    assert_response :redirect
  end
end
