import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["interfaceSelect", "interfaceInfo", "interfacePublicKey", "interfaceListenPort"]
  static values = {
    wireguardInterfaces: Array,
    serverAddress: String
  }

  connect() {
    // 페이지 로드시 첫 번째 인터페이스 선택
    if (this.hasInterfaceSelectTarget && this.interfaceSelectTarget.value) {
      this.updateInterfaceInfo()
    }
  }

  updateInterfaceInfo() {
    if (!this.hasInterfaceSelectTarget) {
      return
    }
    
    const interfaceName = this.interfaceSelectTarget.value
    
    if (!interfaceName) {
      if (this.hasInterfaceInfoTarget) {
        this.interfaceInfoTarget.classList.add('hidden')
      }
      return
    }
    
    const selectedInterface = this.wireguardInterfacesValue.find(iface => iface.name === interfaceName)
    
    if (selectedInterface && this.hasInterfaceInfoTarget) {
      if (this.hasInterfacePublicKeyTarget) {
        this.interfacePublicKeyTarget.textContent = selectedInterface.public_key || '없음'
      }
      if (this.hasInterfaceListenPortTarget) {
        this.interfaceListenPortTarget.textContent = selectedInterface.listen_port || '설정되지 않음'
      }

      const subnetInput = this.element.querySelector("input[name='client[subnet_prefix]'], input[name='subnet_prefix']")
      const allowedIpsInput = this.element.querySelector("input[name='client[allowed_ips]'], input[name='allowed_ips']")

      if (subnetInput) subnetInput.value = ""
      if (allowedIpsInput) allowedIpsInput.value = ""

      fetch(`/clients/fetch_wireguard_address?interface=${encodeURIComponent(interfaceName)}`)
          .then(response => {
            if (!response.ok) throw new Error("API 호출 실패")
            return response.json()
          })
          .then(data => {
            if (data.network) {
              if (subnetInput) subnetInput.value = data.network
              if (allowedIpsInput) allowedIpsInput.value = `${data.network}/24`
              if (data.bridge_network) {
                if (allowedIpsInput) allowedIpsInput.value += `,${data.bridge_network}/24`
              }
            }
          })
          .catch(error => {
            // 네트워크 오류시 무시 (사용자에게 별도 알림 불필요)
          })

      const endpointInput = this.element.querySelector("input[name='client[endpoint]'], input[name='endpoint']")
      if (endpointInput && selectedInterface.listen_port) {
        endpointInput.value = `${this.serverAddressValue}:${selectedInterface.listen_port}`
      }

      this.interfaceInfoTarget.classList.remove('hidden')
    } else if (this.hasInterfaceInfoTarget) {
      this.interfaceInfoTarget.classList.add('hidden')
    }
  }

}