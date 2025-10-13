import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="resend-timer"
export default class extends Controller {
  static targets = ["link", "timer"]
  static values = {
    sentAt: String,
    waitSeconds: { type: Number, default: 63 } // 60 seconds + 3 second buffer
  }

  connect() {
    this.checkTimer()
    this.interval = setInterval(() => this.checkTimer(), 1000)
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  checkTimer() {
    const sentAt = new Date(this.sentAtValue)
    const now = new Date()
    const elapsedSeconds = Math.floor((now - sentAt) / 1000)
    const remainingSeconds = this.waitSecondsValue - elapsedSeconds

    if (remainingSeconds <= 0) {
      this.enableLink()
    } else {
      this.updateTimer(remainingSeconds)
    }
  }

  updateTimer(seconds) {
    if (this.hasTimerTarget) {
      this.timerTarget.textContent = `Resend code (wait ${seconds}s)`
    }
  }

  enableLink() {
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }

    if (this.hasLinkTarget && this.hasTimerTarget) {
      this.linkTarget.classList.remove("hidden")
      this.timerTarget.classList.add("hidden")
    }
  }
}
