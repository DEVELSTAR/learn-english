import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "explanation"]
  static values = { correctIndex: Number }

  select(event) {
    const selectedIndex = parseInt(event.currentTarget.dataset.index)
    
    this.optionTargets.forEach((btn, idx) => {
      btn.disabled = true
      if (idx === this.correctIndexValue) {
        btn.classList.remove("bg-white", "hover:bg-stone-50")
        btn.classList.add("bg-emerald-50", "border-emerald-500", "text-emerald-900", "font-bold")
      } else if (idx === selectedIndex) {
        btn.classList.remove("bg-white", "hover:bg-stone-50")
        btn.classList.add("bg-red-50", "border-red-400", "text-red-900")
      }
    })

    if (this.hasExplanationTarget) {
      this.explanationTarget.classList.remove("hidden")
    }
  }
}

