require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get settings_index_url
    assert_response :success
  end

  test "should get login" do
    get settings_login_url
    assert_response :success
  end

  test "should get logout" do
    get settings_logout_url
    assert_response :success
  end
end
