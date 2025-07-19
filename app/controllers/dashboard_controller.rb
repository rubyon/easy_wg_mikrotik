class DashboardController < ApplicationController
  before_action :require_mikrotik_login

  def index
    @mikrotik_host = session[:mikrotik_host]
    @mikrotik_user = session[:mikrotik_user]
  end
end
