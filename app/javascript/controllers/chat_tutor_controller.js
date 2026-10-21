import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submitButton", "buttonText", "indicator"]

  connect() {
    this.scrollToBottom()
  }

  fillPrompt(event) {
    const prompt = event.currentTarget.dataset.prompt
    if (this.hasInputTarget && prompt) {
      this.inputTarget.value = prompt
      this.inputTarget.style.height = "auto"
      this.inputTarget.style.height = Math.min(this.inputTarget.scrollHeight, 160) + "px"
      this.inputTarget.focus()
      // Move cursor to end
      const len = this.inputTarget.value.length
      this.inputTarget.setSelectionRange(len, len)
    }
  }

  autoResize(event) {
    const textarea = event.target
    textarea.style.height = "auto"
    textarea.style.height = Math.min(textarea.scrollHeight, 160) + "px"
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey && !event.isComposing) {
      event.preventDefault()
      const form = this.element.querySelector("#chat_message_form")
      form?.requestSubmit()
    }
  }

  submitting() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-60", "cursor-not-allowed")
    }
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = "Sending..."
    }
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.remove("hidden")
      this.indicatorTarget.style.display = "flex"
    }
    this.scrollToBottom()
  }

  submitted() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-60", "cursor-not-allowed")
    }
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = "Send"
    }
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add("hidden")
      this.indicatorTarget.style.display = "none"
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.style.height = "auto"
      this.inputTarget.focus()
    }
    this.scrollToBottom()
  }

  scrollToBottom() {
    const container = document.getElementById("chat_messages_container")
    if (container) {
      setTimeout(() => {
        container.scrollTop = container.scrollHeight
      }, 50)
    }
  }
}

