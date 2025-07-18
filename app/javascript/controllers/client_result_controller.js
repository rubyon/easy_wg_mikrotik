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
    const svgElement = document.querySelector('svg')
    const svgData = new XMLSerializer().serializeToString(svgElement)
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const img = new Image()
    
    img.onload = function() {
      canvas.width = img.width
      canvas.height = img.height
      ctx.fillStyle = 'white'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, 0, 0)
      
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