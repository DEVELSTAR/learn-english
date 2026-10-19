import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "form"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      // Use requestAnimationFrame to ensure DOM is fully painted
      requestAnimationFrame(() => {
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
      })
    }
  }

  reset() {
    const input = this.element.querySelector("#chat_message_input")
    if (input) {
      input.value = ""
      input.focus()
    }
    setTimeout(() => this.scrollToBottom(), 50)
  }
}

