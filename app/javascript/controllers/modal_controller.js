import { Controller } from "@hotwired/stimulus"

// Modal controller for handling modal dialogs
export default class extends Controller {
  static targets = ["modal", "backdrop"]

  connect() {
    console.log("Modal controller connected")
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }

  closeBackground(event) {
    if (event.target === this.backdropTarget) {
      this.close(event)
    }
  }
}
