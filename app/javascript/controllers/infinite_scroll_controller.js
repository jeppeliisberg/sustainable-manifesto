import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static values = { containerSelector: String }

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          this.loadMore()
        }
      },
      { threshold: 1 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
  }

  loadMore() {
    const pagyLink = this.element.querySelector(".pagy-nav a[rel='next']")
    if (pagyLink) {
      pagyLink.click()
    }
  }
}
