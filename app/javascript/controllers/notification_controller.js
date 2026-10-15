import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 2000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.classList.add("transition-all", "duration-500", "opacity-0", "-translate-y-2")
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}

