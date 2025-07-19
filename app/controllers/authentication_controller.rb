require "routeros/api"

# MikroTik 라우터 인증 및 세션 관리 컨트롤러
# RouterOS API를 사용한 로그인/로그아웃과 다국어 지원을 담당
class AuthenticationController < ApplicationController
  # 로그인 폼 페이지 표시
  # 이미 로그인된 상태면 대시보드로 리다이렉트
  def login
    redirect_to dashboard_path if logged_in?
  end

  # MikroTik 라우터 인증 처리
  # 사용자 입력 정보로 RouterOS API 연결 시도하고 세션에 저장
  def authenticate
    # 폼에서 전달받은 연결 정보 추출
    host = params[:mikrotik_host].presence
    user = params[:mikrotik_user].presence
    password = params[:mikrotik_password].presence
    port = params[:mikrotik_port].presence || "8728" # 기본 RouterOS API 포트
    ssl = false # 현재 SSL 연결 비활성화
    remember_me = params[:remember_me] == "1"

    # 필수 필드 검증 - 호스트, 사용자명, 비밀번호는 반드시 필요
    if host.blank? || user.blank? || password.blank?
      flash.now[:error] = t("flash.required_fields")
      render :login and return
    end

    begin
      # RouterOS API 객체 생성 및 로그인 시도
      api = RouterOS::API.new(host, port.to_i, ssl: ssl)
      login_response = api.login(user, password)

      if login_response.ok?
        # 로그인 성공시 세션에 연결 정보 저장
        # 추후 MikroTik API 호출시 재사용됨
        session[:mikrotik_host] = host
        session[:mikrotik_user] = user
        session[:mikrotik_password] = password
        session[:mikrotik_port] = port
        session[:mikrotik_ssl] = ssl

        # 로그인 정보 기억하기 처리
        if remember_me
          # 30일간 쿠키에 기본 연결 정보 저장 (비밀번호 제외)
          # Rails가 자동으로 암호화하므로 보안상 안전함
          cookies.permanent[:remember_mikrotik_login] = {
            host: host,
            user: user,
            port: port
          }.to_json
        else
          # 체크박스 해제시 기존 저장된 쿠키 삭제
          cookies.delete(:remember_mikrotik_login)
        end

        api.close
        flash[:success] = t("flash.login_success")
        redirect_to dashboard_path
      else
        # 로그인 실패시 에러 메시지 표시
        flash.now[:error] = t("flash.login_failed")
        render :login
      end
    rescue => e
      # 네트워크 연결 실패 등 예외 처리
      flash.now[:error] = t("flash.connection_failed", error: e.message)
      render :login
    end
  end

  # 로그아웃 처리
  # 세션에서 모든 MikroTik 연결 정보 삭제
  def logout
    session.delete(:mikrotik_host)
    session.delete(:mikrotik_user)
    session.delete(:mikrotik_password)
    session.delete(:mikrotik_port)
    session.delete(:mikrotik_ssl)
    flash[:success] = t("flash.logout_success")
    redirect_to login_path
  end

  # 애플리케이션 언어 변경 처리
  # 지원 언어: 한국어, 영어, 중국어, 일본어
  def change_locale
    locale = params[:locale]
    # 유효한 로케일인지 확인 후 세션에 저장
    if locale.present? && I18n.available_locales.include?(locale.to_sym)
      session[:locale] = locale
      flash[:success] = t("flash.language_changed")
    end

    # 현재 로그인 상태에 따라 적절한 페이지로 리다이렉트
    if logged_in?
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end
end
