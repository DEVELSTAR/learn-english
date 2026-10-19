import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon", "label"]

  toggle() {
    this.contentTargets.forEach(el => el.classList.toggle("hidden"))
    this.iconTargets.forEach(el => el.classList.toggle("rotate-180"))
    this.labelTargets.forEach(el => {
      const expandText = el.getAttribute("data-expand-text") || "Expand"
      const collapseText = el.getAttribute("data-collapse-text") || "Minimize"
      el.textContent = el.textContent.trim() === collapseText ? expandText : collapseText
    })
  }
}
