import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  downloadConfig(event) {
    const clientName = event.params.clientName
    const config = event.params.config
    
    const blob = new Blob([config], { type: 'text/plain' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${clientName}.conf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  }

  downloadQR(event) {
    const clientName = event.params.clientName
    const qrContainer = document.querySelector('#qr-code-container')
    const svgElement = qrContainer.querySelector('svg')
    
    if (!svgElement) {
      console.error('QR code SVG not found')
      return
    }
    
    const svgData = new XMLSerializer().serializeToString(svgElement)
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const img = new Image()
    
    img.onload = function() {
      const padding = 20 // 40px 여백
      canvas.width = img.width + (padding * 2)
      canvas.height = img.height + (padding * 2)
      ctx.fillStyle = 'white'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, padding, padding)
      
      canvas.toBlob(function(blob) {
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `${clientName}-qr.png`
        document.body.appendChild(a)
        a.click()
        window.URL.revokeObjectURL(url)
        document.body.removeChild(a)
      })
    }
    
    img.src = 'data:image/svg+xml;base64,' + btoa(svgData)
  }
}