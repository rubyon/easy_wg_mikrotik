require "routeros/api"

class AuthenticationController < ApplicationController
  def login
    redirect_to dashboard_path if logged_in?
  end

  def authenticate
    host = params[:mikrotik_host].presence
    user = params[:mikrotik_user].presence
    password = params[:mikrotik_password].presence
    port = params[:mikrotik_port].presence || "8728"
    ssl = false
    remember_me = params[:remember_me] == "1"

    if host.blank? || user.blank? || password.blank?
      flash.now[:error] = t("flash.required_fields")
      render :login and return
    end

    begin
      api = RouterOS::API.new(host, port.to_i, ssl: ssl)
      login_response = api.login(user, password)

      if login_response.ok?
        session[:mikrotik_host] = host
        session[:mikrotik_user] = user
        session[:mikrotik_password] = password
        session[:mikrotik_port] = port
        session[:mikrotik_ssl] = ssl

        # 로그인 정보 저장 처리
        if remember_me
          # 30일간 쿠키 저장 (Rails가 자동으로 암호화함)
          cookies.permanent[:remember_mikrotik_login] = {
            host: host,
            user: user,
            port: port
          }.to_json
        else
          # 체크 해제시 쿠키 삭제
          cookies.delete(:remember_mikrotik_login)
        end

        api.close
        flash[:success] = t("flash.login_success")
        redirect_to dashboard_path
      else
        flash.now[:error] = t("flash.login_failed")
        render :login
      end
    rescue => e
      flash.now[:error] = t("flash.connection_failed", error: e.message)
      render :login
    end
  end

  def logout
    session.delete(:mikrotik_host)
    session.delete(:mikrotik_user)
    session.delete(:mikrotik_password)
    session.delete(:mikrotik_port)
    session.delete(:mikrotik_ssl)
    flash[:success] = t("flash.logout_success")
    redirect_to login_path
  end

  # 언어 변경
  def change_locale
    locale = params[:locale]
    if locale.present? && I18n.available_locales.include?(locale.to_sym)
      session[:locale] = locale
      flash[:success] = t("flash.language_changed")
    end

    # 로그인 상태에 따라 리다이렉트
    if logged_in?
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end
end
