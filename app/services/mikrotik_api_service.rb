require "routeros/api"

class MikrotikApiService
  def initialize(session)
    @session = session
  end

  def connect
    return nil unless authenticated?

    api = RouterOS::API.new(
      @session[:mikrotik_host],
      @session[:mikrotik_port].to_i,
      ssl: @session[:mikrotik_ssl]
    )

    if api.login(@session[:mikrotik_user], @session[:mikrotik_password]).ok?
      api
    else
      nil
    end
  end

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

  def fetch_server_public_key(api, interface_name)
    response = api.command("/interface/wireguard/print")
    response.data.each do |iface|
      return iface[:"public-key"] if iface[:name] == interface_name
    end
    nil
  end

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

  private
  def authenticated?
    @session[:mikrotik_host].present? && @session[:mikrotik_user].present?
  end
end
