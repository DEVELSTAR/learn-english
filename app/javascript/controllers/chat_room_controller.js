import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "form"]
  static values = {
    url: String,
    interval: { type: Number, default: 3000 }
  }

  connect() {
    this.scrollToBottom()
    this.startPolling()
    document.addEventListener("visibilitychange", this.handleVisibilityChange)
  }

  disconnect() {
    this.stopPolling()
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
  }

  startPolling() {
    if (!this.hasUrlValue) return
    this.stopPolling()
    this.pollTimer = setInterval(() => this.poll(), this.intervalValue)
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer)
      this.pollTimer = null
    }
  }

  handleVisibilityChange = () => {
    if (!document.hidden) {
      this.poll()
    }
  }

  getLastCommentId() {
    if (!this.hasMessagesTarget) return 0
    const bubbles = this.messagesTarget.querySelectorAll("[id^='lesson_comment_']")
    let maxId = 0
    bubbles.forEach(el => {
      const match = el.id.match(/^lesson_comment_(\d+)$/)
      if (match) {
        const id = parseInt(match[1], 10)
        if (!isNaN(id) && id > maxId) maxId = id
      }
    })
    return maxId
  }

  async poll() {
    if (document.hidden || !this.hasUrlValue || !this.hasMessagesTarget) return

    const lastId = this.getLastCommentId()
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("after_id", lastId)

    try {
      const response = await fetch(url.toString(), {
        headers: { "Accept": "application/json" }
      })

      if (!response.ok) return

      const data = await response.json()
      if (data.comments && data.comments.length > 0) {
        const list = this.element.querySelector("#lesson_comments_list")
        if (!list) return

        const placeholder = this.element.querySelector("#no_comments_placeholder")
        if (placeholder) placeholder.remove()

        // Check if user was near the bottom before appending
        const scrollEl = this.messagesTarget
        const isNearBottom = (scrollEl.scrollHeight - scrollEl.scrollTop - scrollEl.clientHeight) < 120

        let addedCount = 0
        data.comments.forEach(c => {
          if (!document.getElementById("lesson_comment_" + c.id)) {
            list.insertAdjacentHTML("beforeend", c.html)
            addedCount++
          }
        })

        if (data.total_count !== undefined) {
          const countBadge = this.element.querySelector("#lesson_comments_count")
          if (countBadge) countBadge.textContent = data.total_count
        }

        if (addedCount > 0 && isNearBottom) {
          this.scrollToBottom()
        }
      }
    } catch (err) {
      // Silently retry on next poll
    }
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
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
    // Quick sync after posting
    setTimeout(() => this.poll(), 300)
  }
}
