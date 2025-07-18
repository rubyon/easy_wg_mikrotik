import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = { 
    autoHide: { type: Boolean, default: true },
    duration: { type: Number, default: 3000 }
  }

  connect() {
    if (this.autoHideValue) {
      this.startAutoHide()
    }
  }

  startAutoHide() {
    this.timeout = setTimeout(() => {
      this.hide()
    }, this.durationValue)
  }

  hide() {
    this.element.style.opacity = '0'
    setTimeout(() => {
      if (this.element.parentElement) {
        this.element.remove()
      }
    }, 300)
  }

  close(event) {
    event.preventDefault()
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.hide()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}