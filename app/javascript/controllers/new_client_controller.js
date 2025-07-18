import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["interfaceSelect", "interfaceInfo", "interfacePublicKey", "interfaceListenPort"]
  static values = { wireguardInterfaces: Array }

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
      
      this.interfaceInfoTarget.classList.remove('hidden')
    } else if (this.hasInterfaceInfoTarget) {
      this.interfaceInfoTarget.classList.add('hidden')
    }
  }

}