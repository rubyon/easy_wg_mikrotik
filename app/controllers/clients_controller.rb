require "routeros/api"
require "rqrcode"
require "rbnacl"
require "base64"

# WireGuard 클라이언트 관리 컨트롤러
# MikroTik 라우터의 WireGuard 피어 생성, 조회, 삭제 기능을 담당
# QR 코드와 설정 파일 생성으로 모바일 및 데스크톱 클라이언트 지원
class ClientsController < ApplicationController
  before_action :require_mikrotik_login

  # 클라이언트 IP 할당 시작 번호 (.2부터 할당)
  START_IP = 2

  # 새 클라이언트 생성 폼 페이지
  # MikroTik에서 WireGuard 인터페이스 목록을 가져와서 선택할 수 있도록 표시
  def new
    begin
      # MikroTik API 연결 및 WireGuard 인터페이스 조회
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to root_path and return
      end

      # 활성화된 WireGuard 인터페이스만 가져오기
      @wireguard_interfaces = fetch_wireguard_interfaces(api)
      api.close

      # WireGuard 인터페이스가 없으면 에러 처리
      if @wireguard_interfaces.empty?
        flash[:error] = t("flash.no_wireguard_interfaces")
        redirect_to root_path and return
      end

      # URL 파라미터로 전달된 기본 선택 인터페이스 설정
      @selected_interface = params[:interface]
    rescue
      # 네트워크 오류 등 예외 상황 처리
      flash[:error] = t("flash.wireguard_interface_error")
      redirect_to root_path
    end
  end

  # WireGuard 클라이언트 생성 처리
  # 키 페어 생성, IP 할당, MikroTik 피어 등록, 설정 파일 및 QR 코드 생성
  def create
    # 폼에서 전달받은 클라이언트 설정 정보 추출
    interface_name = params[:interface_name]
    endpoint = params[:endpoint]
    allowed_ips = params[:allowed_ips]
    subnet_prefix = params[:subnet_prefix].to_s.split(".")[0, 3].join(".")
    persistent_keepalive = params[:persistent_keepalive]
    dns = params[:dns]

    # 인터페이스 이름 필수 검증
    unless interface_name.present?
      flash[:error] = t("flash.interface_required")
      redirect_to new_client_path and return
    end

    # 나머지 필수 필드들 검증
    unless endpoint.present? && allowed_ips.present? && subnet_prefix.present? && persistent_keepalive.present?
      flash[:error] = t("flash.config_fields_required")
      redirect_to new_client_path and return
    end

    begin
      # MikroTik API 연결 확인
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to new_client_path and return
      end

      # 1단계: 클라이언트용 WireGuard 키 페어 생성 (NaCl 라이브러리 사용)
      private_key, public_key = generate_wireguard_keypair

      # 2단계: 선택된 WireGuard 인터페이스의 서버 공개키 조회
      server_public_key = fetch_server_public_key(api, interface_name)
      unless server_public_key
        flash[:error] = t("flash.server_public_key_error")
        api.close
        redirect_to new_client_path and return
      end

      # 3단계: 현재 등록된 피어 목록 조회하여 IP 충돌 방지
      peers_response = api.command("/interface/wireguard/peers/print")
      unless peers_response.ok?
        flash[:error] = t("flash.peers_list_error")
        api.close
        redirect_to new_client_path and return
      end

      # 선택된 인터페이스에 등록된 피어만 필터링
      interface_peers = peers_response.data.select { |peer| peer[:interface] == interface_name }

      # 사용 가능한 다음 IP 주소 계산
      client_address = next_client_address(interface_peers, subnet_prefix)

      # 클라이언트 이름 설정 - 입력하지 않으면 IP 기반으로 자동 생성
      client_name = params[:client_name].presence || "Client-#{client_address.split('/')[0]}"

      # 4단계: MikroTik 라우터에 새 피어 등록
      add_peer_response = register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
      unless add_peer_response.ok?
        flash[:error] = t("flash.peer_registration_failed", error: add_peer_response.data)
        api.close
        redirect_to new_client_path and return
      end

      # 5단계: 클라이언트용 WireGuard 설정 파일 생성
      @client_config = generate_client_config(private_key, client_address, server_public_key, endpoint, allowed_ips, persistent_keepalive, dns)

      # 6단계: 모바일 앱 설정용 QR 코드 생성
      @qr_code = generate_qr_code(@client_config)

      # 결과 페이지 표시용 데이터 설정
      @client_name = client_name
      @client_address = client_address
      @interface_name = interface_name
      @endpoint = endpoint
      @allowed_ips = allowed_ips
      @persistent_keepalive = persistent_keepalive
      @success = true

      api.close
      flash.now[:success] = t("flash.client_created")
      render :result
    rescue => e
      # 전체 프로세스 중 예외 발생시 에러 처리
      flash[:error] = t("flash.client_creation_error", error: e.message)
      redirect_to new_client_path
    end
  end

  # 등록된 WireGuard 클라이언트 목록 조회
  # 인터페이스별 필터링 기능과 실시간 피어 정보 표시
  def index
    begin
      # MikroTik API 연결 및 데이터 조회
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to root_path and return
      end

      # 드롭다운 선택용 WireGuard 인터페이스 목록 가져오기
      @wireguard_interfaces = fetch_wireguard_interfaces(api)

      # 모든 WireGuard 피어 목록 조회
      peers_response = api.command("/interface/wireguard/peers/print")
      if peers_response.ok?
        @peers = peers_response.data

        # 특정 인터페이스 선택시 해당 인터페이스의 피어만 필터링
        if params[:interface].present?
          @peers = @peers.select { |peer| peer[:interface] == params[:interface] }
          @selected_interface = params[:interface]
        end
      else
        @peers = []
        flash.now[:error] = t("flash.peers_list_error")
      end

      api.close
    rescue
      # 네트워크 오류 등 예외 발생시 빈 배열로 초기화
      @peers = []
      @wireguard_interfaces = []
      flash.now[:error] = t("flash.peers_list_error")
    end
  end

  # WireGuard 클라이언트 삭제 처리
  # Turbo Stream을 사용한 실시간 UI 업데이트와 JSON API 지원
  def destroy
    peer_id = params[:id]

    begin
      # MikroTik API 연결 확인
      api = mikrotik_api
      unless api
        respond_to do |format|
          format.turbo_stream {
            flash.now[:error] = t("flash.mikrotik_connection_failed")
            render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
          }
          format.json { render json: { success: false, error: t("flash.mikrotik_connection_failed") } }
        end
        return
      end

      # MikroTik에서 피어 삭제 실행
      delete_response = api.command("/interface/wireguard/peers/remove", { ".id" => peer_id })

      if delete_response.ok?
        api.close
        # 삭제 성공시 Turbo Stream으로 실시간 UI 업데이트
        respond_to do |format|
          format.turbo_stream {
            flash.now[:success] = t("flash.client_deleted")
            render turbo_stream: [
              turbo_stream.remove("peer_#{peer_id}"),
              turbo_stream.replace("flash", partial: "shared/flash")
            ]
          }
          format.json { render json: { success: true, message: t("flash.client_deleted") } }
        end
      else
        api.close
        # 삭제 실패시 에러 메시지 표시
        respond_to do |format|
          format.turbo_stream {
            flash.now[:error] = t("flash.client_delete_failed", error: delete_response.data)
            render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
          }
          format.json { render json: { success: false, error: t("flash.client_delete_failed", error: delete_response.data) } }
        end
      end
    rescue => e
      # 네트워크 오류 등 예외 상황 처리
      respond_to do |format|
        format.turbo_stream {
          flash.now[:error] = t("flash.client_delete_failed", error: e.message)
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
        }
        format.json { render json: { success: false, error: t("flash.client_delete_failed", error: e.message) } }
      end
    end
  end

  # AJAX로 WireGuard 인터페이스의 네트워크 주소 정보 조회
  # 클라이언트 생성 폼에서 인터페이스 선택시 동적으로 서브넷 정보 로드
  def fetch_wireguard_address
    api = mikrotik_api
    unless api
      render json: { error: t("flash.mikrotik_connection_failed") }, status: :service_unavailable and return
    end

    # MikroTik에서 IP 주소 설정 정보 조회
    response = api.command("/ip/address/print")
    unless response.ok?
      render json: { error: t("flash.connection_failed", error: "API response failed") }, status: :bad_gateway and return
    end

    # 선택된 인터페이스와 bridge1의 네트워크 정보 검색
    iface = response.data.find { |entry| entry[:interface] == params[:interface] }
    bridge_iface = response.data.find { |entry| entry[:interface] == "bridge1" }

    if iface
      # 해당 인터페이스의 네트워크 정보와 브리지 네트워크 정보 반환
      render json:   {
               network:        iface[:network],
               bridge_network: bridge_iface&.[](:network)
             },
             status: :ok
    else
      render json: { error: t("flash.interface_required") }, status: :not_found
    end
  end

  private
  # MikroTik API 서비스 인스턴스 생성 및 연결
  # 세션에 저장된 로그인 정보를 사용하여 RouterOS API 연결
  def mikrotik_api
    @mikrotik_service ||= MikrotikApiService.new(session)
    @mikrotik_service.connect
  end

  # WireGuard 클라이언트용 키 페어 생성
  # NaCl 라이브러리를 사용하여 암호학적으로 안전한 개인키/공개키 쌍 생성
  # Base64 인코딩된 문자열 형태로 반환 [개인키, 공개키]
  def generate_wireguard_keypair
    private_key = RbNaCl::PrivateKey.generate
    public_key = private_key.public_key
    [
      Base64.strict_encode64(private_key.to_bytes),
      Base64.strict_encode64(public_key.to_bytes)
    ]
  end

  # MikroTik에서 활성화된 WireGuard 인터페이스 목록 조회
  # 비활성화된 인터페이스는 자동으로 제외됨
  def fetch_wireguard_interfaces(api)
    @mikrotik_service ||= MikrotikApiService.new(session)
    @mikrotik_service.fetch_wireguard_interfaces(api)
  end

  # 지정된 WireGuard 인터페이스의 서버 공개키 조회
  # 클라이언트 설정 파일 생성시 필요한 서버측 공개키 정보
  def fetch_server_public_key(api, interface_name)
    @mikrotik_service ||= MikrotikApiService.new(session)
    @mikrotik_service.fetch_server_public_key(api, interface_name)
  end

  # 클라이언트에게 할당할 사용 가능한 다음 IP 주소 계산
  # 기존 피어들의 IP를 검사하여 충돌하지 않는 새로운 IP 자동 할당
  # START_IP(2)부터 시작하여 순차적으로 빈 번호 찾기
  def next_client_address(peers, subnet_prefix)
    used_ips = peers.map do |peer|
      addr = peer[:"allowed-address"]
      if addr&.start_with?("#{subnet_prefix}.")
        addr.split("/").first.split(".").last.to_i
      end
    end.compact.uniq.sort

    # 사용 중인 IP 목록에서 비어있는 첫 번째 번호 찾아서 할당
    ip = START_IP
    while used_ips.include?(ip)
      ip += 1
    end

    "#{subnet_prefix}.#{ip}/32"
  end

  # MikroTik 라우터에 새로운 WireGuard 피어 등록
  # 클라이언트 정보를 RouterOS에 추가하여 VPN 연결 허용
  def register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
    @mikrotik_service ||= MikrotikApiService.new(session)
    @mikrotik_service.register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
  end

  # 클라이언트용 WireGuard 설정 파일 생성
  # .conf 파일 형식으로 클라이언트에서 바로 사용 가능한 설정 텍스트 생성
  # [Interface] 섹션과 [Peer] 섹션을 포함한 완전한 설정 파일
  # DNS가 비어있을 경우 DNS 라인은 제외됨
  def generate_client_config(private_key, address, server_pubkey, endpoint, allowed_ips, persistent_keepalive, dns = nil)
    # Interface 섹션 구성
    interface_section = <<~INTERFACE
      [Interface]
      PrivateKey = #{private_key}
      Address = #{address}
    INTERFACE

    # DNS가 입력되었고 비어있지 않으면 DNS 라인 추가
    if dns.present?
      interface_section += "DNS = #{dns}\n"
    end

    # Peer 섹션 구성
    peer_section = <<~PEER

      [Peer]
      PublicKey = #{server_pubkey}
      Endpoint = #{endpoint}
      AllowedIPs = #{allowed_ips}
      PersistentKeepalive = #{persistent_keepalive}
    PEER

    # 전체 설정 파일 반환
    interface_section + peer_section
  end

  # 모바일 WireGuard 앱용 QR 코드 생성
  # 설정 파일 내용을 QR 코드로 변환하여 모바일에서 쉽게 스캔 가능
  # SVG 형식으로 생성되어 웹 페이지에서 직접 표시 가능
  def generate_qr_code(data)
    qrcode = RQRCode::QRCode.new(data, level: :l)
    qrcode.as_svg(
      offset:          0,          # 여백 없음
      color:           "000",      # 검은색 코드
      shape_rendering: "crispEdges", # 선명한 모서리
      module_size:     6,          # 모듈 크기 (픽셀)
      standalone:      true        # 독립 실행 가능한 SVG
    ).html_safe
  end
end
