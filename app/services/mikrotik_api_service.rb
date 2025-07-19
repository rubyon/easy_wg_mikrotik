require "routeros/api"

# MikroTik RouterOS API 연동 서비스
# WireGuard 관련 모든 MikroTik API 호출을 캡슐화하여 컨트롤러에서 분리
# 세션 기반 인증 정보를 사용하여 RouterOS와 안전한 통신 제공
class MikrotikApiService
  # 세션 정보를 받아서 서비스 인스턴스 초기화
  # 세션에는 MikroTik 연결에 필요한 모든 정보가 포함됨
  def initialize(session)
    @session = session
  end

  # RouterOS API 연결 생성 및 인증
  # 세션에 저장된 연결 정보를 사용하여 MikroTik 라우터에 로그인
  # 성공시 API 객체 반환, 실패시 nil 반환
  def connect
    return nil unless authenticated?

    # RouterOS API 객체 생성 (호스트, 포트, SSL 설정)
    api = RouterOS::API.new(
      @session[:mikrotik_host],
      @session[:mikrotik_port].to_i,
      ssl: @session[:mikrotik_ssl]
    )

    # 사용자 인증 시도
    if api.login(@session[:mikrotik_user], @session[:mikrotik_password]).ok?
      api
    else
      nil
    end
  end

  # MikroTik에서 활성화된 WireGuard 인터페이스 목록 조회
  # 비활성화된 인터페이스는 자동으로 제외하여 사용 가능한 인터페이스만 반환
  def fetch_wireguard_interfaces(api)
    response = api.command("/interface/wireguard/print")
    if response.ok?
      # 인터페이스 정보를 해시 형태로 변환하고 비활성화된 것 제외
      response.data.map do |iface|
        {
          name:        iface[:name],
          public_key:  iface[:"public-key"],
          listen_port: iface[:"listen-port"],
          disabled:    iface[:disabled] == "true"
        }
      end.reject { |iface| iface[:disabled] }
    else
      []
    end
  end

  # 지정된 WireGuard 인터페이스의 서버 공개키 조회
  # 클라이언트 설정 파일 생성시 필요한 서버측 공개키 정보 추출
  def fetch_server_public_key(api, interface_name)
    response = api.command("/interface/wireguard/print")
    response.data.each do |iface|
      return iface[:"public-key"] if iface[:name] == interface_name
    end
    nil
  end

  # MikroTik에 새로운 WireGuard 피어 등록
  # 클라이언트 정보를 RouterOS에 추가하여 VPN 연결 허용
  # 피어 이름, 인터페이스, 공개키, 허용 주소, keepalive 설정 포함
  def register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
    api.command(
      "/interface/wireguard/peers/add",
      {
        "name"                 => client_name,           # 피어 식별 이름
        "interface"            => interface_name,        # 연결할 WireGuard 인터페이스
        "public-key"           => public_key,            # 클라이언트 공개키
        "allowed-address"      => client_address,        # 클라이언트에게 할당된 IP 주소
        "persistent-keepalive" => persistent_keepalive.to_s # 연결 유지 주기 (초)
      }
    )
  end

  private
  # 세션에 MikroTik 인증 정보가 올바르게 저장되어 있는지 확인
  # 최소한 호스트와 사용자명이 있어야 API 연결 시도 가능
  def authenticated?
    @session[:mikrotik_host].present? && @session[:mikrotik_user].present?
  end
end
