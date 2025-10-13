import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turnstile"
export default class extends Controller {
  static targets = ["widget"]

  connect() {
    // Reset the widget when the controller connects
    // This handles the case when the form is re-rendered after an error
    this.resetWidget()
  }

  resetWidget() {
    // Check if Turnstile is loaded and the widget exists
    if (typeof turnstile !== 'undefined' && this.hasWidgetTarget) {
      const widgetId = this.widgetTarget.getAttribute('data-widget-id')

      if (widgetId) {
        // Reset existing widget
        turnstile.reset(widgetId)
      } else {
        // Render new widget and store its ID
        const sitekey = this.widgetTarget.getAttribute('data-sitekey')
        const newWidgetId = turnstile.render(this.widgetTarget, {
          sitekey: sitekey
        })
        this.widgetTarget.setAttribute('data-widget-id', newWidgetId)
      }
    }
  }
}
