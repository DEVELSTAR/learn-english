import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String,
    lang: { type: String, default: "en-IN" },
    audioUrl: { type: String, default: "" }
  }
  static targets = ["button", "icon", "label"]

  connect() {
    this.isPlaying = false
    this.audioElement = null
    this.sentenceQueue = []
    this.currentIndex = 0
    this.keepAliveTimer = null
  }

  disconnect() {
    this.stop()
  }

  toggle(event) {
    event?.preventDefault()
    event?.stopPropagation()

    if (this.isPlaying) {
      this.stop()
    } else {
      this.play()
    }
  }

  play() {
    this.stopAllActiveSpeech()

    // 1. If custom voice audio URL is provided (Akib Sir's recorded/cloned voice), play it!
    if (this.audioUrlValue && this.audioUrlValue.length > 0) {
      this.playCustomAudio(this.audioUrlValue)
      return
    }

    // 2. Otherwise, use high-quality Web Speech API synthesis
    if (!("speechSynthesis" in window)) {
      alert("Text-to-speech is not supported by your browser.")
      return
    }

    const textToSpeak = this.cleanText(this.textValue || this.element.dataset.speakerText || this.element.innerText)
    if (!textToSpeak) return

    window.speechSynthesis.cancel()

    // Break into sentences so long lessons/topics play reliably without Chrome's 15s timeout
    this.sentenceQueue = this.splitIntoChunks(textToSpeak)
    this.currentIndex = 0

    if (this.sentenceQueue.length === 0) return

    this.setPlayingState(true)
    this.startKeepAlive()
    this.speakNext()
  }

  speakNext() {
    if (!this.isPlaying) return

    if (this.currentIndex >= this.sentenceQueue.length) {
      this.stop()
      return
    }

    const chunk = this.sentenceQueue[this.currentIndex]
    const utterance = new SpeechSynthesisUtterance(chunk)
    utterance.rate = 0.95 // Natural, learner-friendly pace
    utterance.pitch = 1.0

    const voices = window.speechSynthesis.getVoices()
    const preferredVoice = voices.find(v => v.lang === "en-IN") ||
                           voices.find(v => v.lang.startsWith("en-GB") && v.name.includes("Natural")) ||
                           voices.find(v => v.lang.startsWith("en-US") && v.name.includes("Natural")) ||
                           voices.find(v => v.lang.startsWith("en"))

    if (preferredVoice) {
      utterance.voice = preferredVoice
    }

    utterance.onend = () => {
      this.currentIndex++
      this.speakNext()
    }

    utterance.onerror = (e) => {
      console.warn("[SpeakerController] Speech error:", e)
      this.stop()
    }

    this.currentUtterance = utterance
    window.speechSynthesis.speak(utterance)
  }

  startKeepAlive() {
    this.stopKeepAlive()
    this.keepAliveTimer = setInterval(() => {
      if (window.speechSynthesis && window.speechSynthesis.speaking && !window.speechSynthesis.paused) {
        window.speechSynthesis.pause()
        window.speechSynthesis.resume()
      }
    }, 5000)
  }

  stopKeepAlive() {
    if (this.keepAliveTimer) {
      clearInterval(this.keepAliveTimer)
      this.keepAliveTimer = null
    }
  }

  playCustomAudio(url) {
    this.audioElement = new Audio(url)
    this.setPlayingState(true)

    this.audioElement.onended = () => {
      this.setPlayingState(false)
      this.audioElement = null
    }

    this.audioElement.onerror = () => {
      this.setPlayingState(false)
      this.audioElement = null
    }

    this.audioElement.play().catch(e => {
      console.warn("[SpeakerController] Audio play failed:", e)
      this.setPlayingState(false)
    })
  }

  stop() {
    this.stopKeepAlive()
    this.sentenceQueue = []
    this.currentIndex = 0

    if (this.audioElement) {
      this.audioElement.pause()
      this.audioElement.currentTime = 0
      this.audioElement = null
    }

    if ("speechSynthesis" in window) {
      window.speechSynthesis.cancel()
    }

    this.setPlayingState(false)
  }

  stopAllActiveSpeech() {
    if ("speechSynthesis" in window) {
      window.speechSynthesis.cancel()
    }
    document.querySelectorAll("[data-controller*='speaker']").forEach(el => {
      const controller = this.application.getControllerForElementAndIdentifier(el, "speaker")
      if (controller && controller !== this) {
        controller.stop()
      }
    })
  }

  setPlayingState(isPlaying) {
    this.isPlaying = isPlaying

    if (this.hasLabelTarget) {
      const currentLabel = this.labelTarget.textContent.trim()
      if (isPlaying) {
        this.originalLabel = this.labelTarget.dataset.originalLabel || currentLabel
        this.labelTarget.dataset.originalLabel = this.originalLabel
        this.labelTarget.textContent = "Stop"
      } else {
        this.labelTarget.textContent = this.labelTarget.dataset.originalLabel || "Listen"
      }
    }

    if (this.hasIconTarget) {
      this.iconTarget.textContent = isPlaying ? "⏹" : "🔊"
    }

    if (this.hasButtonTarget) {
      if (isPlaying) {
        this.buttonTarget.classList.add("bg-emerald-600", "text-white", "animate-pulse")
        this.buttonTarget.classList.remove("bg-emerald-50", "text-emerald-800", "text-emerald-700")
      } else {
        this.buttonTarget.classList.remove("bg-emerald-600", "text-white", "animate-pulse")
        this.buttonTarget.classList.add("bg-emerald-50", "text-emerald-800")
      }
    }
  }

  cleanText(raw) {
    if (!raw) return ""
    return raw
      .replace(/<[^>]*>/g, " ")       // Remove HTML tags
      .replace(/[*_#`~>]/g, "")       // Remove markdown formatting
      .replace(/\s+/g, " ")           // Collapse spaces
      .trim()
  }

  splitIntoChunks(text) {
    if (!text) return []
    // Split on sentence boundaries (. ! ? \n)
    const sentences = text.match(/[^.!?\n]+[.!?\n]+/g)
    if (!sentences || sentences.length === 0) {
      return [text]
    }
    return sentences.map(s => s.trim()).filter(s => s.length > 0)
  }
}
