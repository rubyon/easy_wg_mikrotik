import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.hideOnClickOutside.bind(this))
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.hideOnClickOutside.bind(this))
  }

  hideOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.hideOnClickOutside.bind(this))
  }
}