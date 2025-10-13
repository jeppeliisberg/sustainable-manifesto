import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share-button"
export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String,
  }

  connect() {
    // Hide the button if the Web Share API and clipboard are both unavailable.
    if (!navigator.share && !navigator.clipboard) {
      this.element.style.display = 'none'
    }
  }

  async share(event) {
    event.preventDefault()

    const shareData = {
      title: this.titleValue,
      text: this.textValue,
      url: this.urlValue || window.location.href,
    }

    if (navigator.share) {
      try {
        // Use Web Share API if available
        await navigator.share(shareData)
      } catch (err) {
        // Silently catch errors from user cancelling the share dialog
        if (err.name !== 'AbortError') {
          console.error("Share failed:", err)
        }
      }
    } else if (navigator.clipboard) {
      // Fallback to copying the link to the clipboard
      this.copyLink()
    }
  }

  copyLink() {
    navigator.clipboard.writeText(this.urlValue || window.location.href).then(() => {
      const originalText = this.element.textContent
      this.element.textContent = 'Link Copied!'
      setTimeout(() => {
        this.element.textContent = originalText
      }, 2000)
    }).catch(err => {
      console.error('Failed to copy: ', err)
    })
  }
}
