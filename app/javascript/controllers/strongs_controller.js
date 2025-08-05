import { Controller } from "@hotwired/stimulus"

// Stimulus controller for Strong's concordance popup management
export default class extends Controller {
  static targets = ["frame"]
  static values = { 
    strongNumber: String
  }

  connect() {
    // Listen for close popup events from other controllers
    this.element.addEventListener("bible-navigation:closePopups", this.close.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("bible-navigation:closePopups", this.close.bind(this))
  }

  // Show Strong's definition popup
  show(event) {
    event.preventDefault()
    
    const strongNumber = event.currentTarget.dataset.strongNumber
    if (!strongNumber) return
    
    this.strongNumberValue = strongNumber
    this.loadDefinition()
  }

  // Load Strong's definition using Turbo Frame
  loadDefinition() {
    // Use Turbo to load the content into the frame
    this.frameTarget.src = `/strongs/${this.strongNumberValue}`
  }

  // Close the popup by clearing the frame
  close() {
    if (this.hasFrameTarget) {
      this.frameTarget.innerHTML = ""
    }
  }
}