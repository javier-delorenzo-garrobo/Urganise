import { Controller } from "@hotwired/stimulus"

// Dropdown controller for handling dropdown menus
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuTarget.classList.add("hidden")
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  disconnect() {
    this.menuTarget.classList.add("hidden")
  }
}
