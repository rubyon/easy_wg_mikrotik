require "routeros/api"
require "rqrcode"
require "rbnacl"
require "base64"

class ClientsController < ApplicationController
  before_action :require_mikrotik_login

  START_IP = 2

  def new
    # WireGuard 인터페이스 목록 가져오기
    begin
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to root_path and return
      end

      @wireguard_interfaces = fetch_wireguard_interfaces(api)
      api.close

      if @wireguard_interfaces.empty?
        flash[:error] = t("flash.no_wireguard_interfaces")
        redirect_to root_path and return
      end

      # URL 파라미터에서 선택할 인터페이스 설정
      @selected_interface = params[:interface]
    rescue
      flash[:error] = t("flash.wireguard_interface_error")
      redirect_to root_path
    end
  end

  def create
    interface_name = params[:interface_name]
    endpoint = params[:endpoint]
    allowed_ips = params[:allowed_ips]
    subnet_prefix = params[:subnet_prefix].to_s.split(".")[0, 3].join(".")
    persistent_keepalive = params[:persistent_keepalive]

    # 필수 필드 검증
    unless interface_name.present?
      flash[:error] = t("flash.interface_required")
      redirect_to new_client_path and return
    end

    unless endpoint.present? && allowed_ips.present? && subnet_prefix.present? && persistent_keepalive.present?
      flash[:error] = t("flash.config_fields_required")
      redirect_to new_client_path and return
    end

    begin
      # MikroTik API 연결
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to new_client_path and return
      end

      # 1. WireGuard 키 페어 생성
      private_key, public_key = generate_wireguard_keypair

      # 2. 서버 공개키 조회
      server_public_key = fetch_server_public_key(api, interface_name)
      unless server_public_key
        flash[:error] = t("flash.server_public_key_error")
        api.close
        redirect_to new_client_path and return
      end

      # 3. 피어 목록 조회
      peers_response = api.command("/interface/wireguard/peers/print")
      unless peers_response.ok?
        flash[:error] = t("flash.peers_list_error")
        api.close
        redirect_to new_client_path and return
      end

      # 선택된 인터페이스의 피어만 필터링
      interface_peers = peers_response.data.select { |peer| peer[:interface] == interface_name }

      client_address = next_client_address(interface_peers, subnet_prefix)

      # 클라이언트 이름 설정 (비어있으면 할당받은 IP로 자동 생성)
      client_name = params[:client_name].presence || "Client-#{client_address.split('/')[0]}"

      # 4. MikroTik에 피어 등록
      add_peer_response = register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
      unless add_peer_response.ok?
        flash[:error] = t("flash.peer_registration_failed", error: add_peer_response.data)
        api.close
        redirect_to new_client_path and return
      end

      # 5. 클라이언트 설정 파일 생성
      @client_config = generate_client_config(private_key, client_address, server_public_key, endpoint, allowed_ips, persistent_keepalive)

      # 6. QR 코드 생성
      @qr_code = generate_qr_code(@client_config)

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
      flash[:error] = t("flash.client_creation_error", error: e.message)
      redirect_to new_client_path
    end
  end

  def index
    begin
      api = mikrotik_api
      unless api
        flash[:error] = t("flash.mikrotik_connection_failed")
        redirect_to root_path and return
      end

      # WireGuard 인터페이스 목록도 가져오기
      @wireguard_interfaces = fetch_wireguard_interfaces(api)

      peers_response = api.command("/interface/wireguard/peers/print")
      if peers_response.ok?
        @peers = peers_response.data

        # 선택된 인터페이스로 필터링
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
      @peers = []
      @wireguard_interfaces = []
      flash.now[:error] = t("flash.peers_list_error")
    end
  end

  def destroy
    peer_id = params[:id]

    begin
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

      # 피어 삭제
      delete_response = api.command("/interface/wireguard/peers/remove", { ".id" => peer_id })

      if delete_response.ok?
        api.close
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
        respond_to do |format|
          format.turbo_stream {
            flash.now[:error] = t("flash.client_delete_failed", error: delete_response.data)
            render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
          }
          format.json { render json: { success: false, error: t("flash.client_delete_failed", error: delete_response.data) } }
        end
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream {
          flash.now[:error] = t("flash.client_delete_failed", error: e.message)
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
        }
        format.json { render json: { success: false, error: t("flash.client_delete_failed", error: e.message) } }
      end
    end
  end

  def fetch_wireguard_address
    api = mikrotik_api
    unless api
      render json: { error: t("flash.mikrotik_connection_failed") }, status: :service_unavailable and return
    end

    response = api.command("/ip/address/print")
    unless response.ok?
      render json: { error: t("flash.connection_failed", error: "API response failed") }, status: :bad_gateway and return
    end

    iface = response.data.find { |entry| entry[:interface] == params[:interface] }
    bridge_iface = response.data.find { |entry| entry[:interface] == "bridge1" }
    if iface
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
  def mikrotik_api
    return nil unless logged_in?

    api = RouterOS::API.new(
      session[:mikrotik_host],
      session[:mikrotik_port].to_i,
      ssl: session[:mikrotik_ssl]
    )

    if api.login(session[:mikrotik_user], session[:mikrotik_password]).ok?
      api
    else
      nil
    end
  end

  # WireGuard 키 페어 생성
  def generate_wireguard_keypair
    private_key = RbNaCl::PrivateKey.generate
    public_key = private_key.public_key
    [
      Base64.strict_encode64(private_key.to_bytes),
      Base64.strict_encode64(public_key.to_bytes)
    ]
  end

  # WireGuard 인터페이스 목록 조회
  def fetch_wireguard_interfaces(api)
    response = api.command("/interface/wireguard/print")
    if response.ok?
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

  # 서버 공개키 조회
  def fetch_server_public_key(api, interface_name)
    response = api.command("/interface/wireguard/print")
    response.data.each do |iface|
      return iface[:"public-key"] if iface[:name] == interface_name
    end
    nil
  end

  # 사용 가능한 IP 탐색
  def next_client_address(peers, subnet_prefix)
    used_ips = peers.map do |peer|
      addr = peer[:"allowed-address"]
      if addr&.start_with?("#{subnet_prefix}.")
        addr.split("/").first.split(".").last.to_i
      end
    end.compact.uniq.sort

    # 비어있는 구간 찾아서 할당
    ip = START_IP
    while used_ips.include?(ip)
      ip += 1
    end

    "#{subnet_prefix}.#{ip}/32"
  end

  # 피어 등록
  def register_peer(api, public_key, client_address, client_name, interface_name, persistent_keepalive)
    api.command(
      "/interface/wireguard/peers/add",
      {
        "name"                 => client_name,
        "interface"            => interface_name,
        "public-key"           => public_key,
        "allowed-address"      => client_address,
        "persistent-keepalive" => persistent_keepalive.to_s
      }
    )
  end

  # 클라이언트 설정 파일 생성
  def generate_client_config(private_key, address, server_pubkey, endpoint, allowed_ips, persistent_keepalive)
    <<~CONF
      [Interface]
      PrivateKey = #{private_key}
      Address = #{address}

      [Peer]
      PublicKey = #{server_pubkey}
      Endpoint = #{endpoint}
      AllowedIPs = #{allowed_ips}
      PersistentKeepalive = #{persistent_keepalive}
    CONF
  end

  # QR 코드 생성
  def generate_qr_code(data)
    qrcode = RQRCode::QRCode.new(data, level: :l)
    qrcode.as_svg(
      offset:          0,
      color:           "000",
      shape_rendering: "crispEdges",
      module_size:     6,
      standalone:      true
    )
  end
end
