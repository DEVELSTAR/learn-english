import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "showText", "hideText"]

  toggle() {
    this.inputTargets.forEach(input => {
      if (input.type === "password") {
        input.type = "text"
      } else {
        input.type = "password"
      }
    })

    if (this.hasShowTextTarget && this.hasHideTextTarget) {
      this.showTextTarget.classList.toggle("hidden")
      this.hideTextTarget.classList.toggle("hidden")
    }
  }
}

