import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="code-input"
export default class extends Controller {
  static targets = ["digit", "hiddenField"]

  connect() {
    this.updateHiddenField()
  }

  handleInput(event) {
    const input = event.target
    const value = input.value

    // Only allow alphanumeric characters
    if (value && !/^[A-Za-z0-9]$/.test(value)) {
      input.value = ""
      return
    }

    // Move to next input if there's a value
    if (value) {
      const nextInput = this.getNextInput(input)
      if (nextInput) {
        nextInput.focus()
        nextInput.select()
      }
    }

    this.updateHiddenField()
  }

  handleBackspace(event) {
    const input = event.target

    // If backspace is pressed and input is empty, move to previous
    if (event.key === "Backspace" && !input.value) {
      event.preventDefault()
      const prevInput = this.getPreviousInput(input)
      if (prevInput) {
        prevInput.focus()
        prevInput.select()
      }
    }

    this.updateHiddenField()
  }

  handlePaste(event) {
    event.preventDefault()
    const pastedData = event.clipboardData.getData("text").trim()

    // Only process if it's exactly 6 characters
    if (pastedData.length === 6 && /^[A-Za-z0-9]{6}$/.test(pastedData)) {
      this.digitTargets.forEach((input, index) => {
        input.value = pastedData[index] || ""
      })
      this.updateHiddenField()
      // Focus last input
      this.digitTargets[5].focus()
    }
  }

  updateHiddenField() {
    const code = this.digitTargets.map(input => input.value).join("")
    this.hiddenFieldTarget.value = code
  }

  getNextInput(currentInput) {
    const currentIndex = this.digitTargets.indexOf(currentInput)
    return this.digitTargets[currentIndex + 1]
  }

  getPreviousInput(currentInput) {
    const currentIndex = this.digitTargets.indexOf(currentInput)
    return this.digitTargets[currentIndex - 1]
  }
}
