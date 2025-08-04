import { Controller } from "@hotwired/stimulus"

// Stimulus controller for Strong's concordance popup management
export default class extends Controller {
  static targets = ["popup", "backdrop", "frame"]
  static values = { 
    strongNumber: String,
    loadingText: String,
    errorText: String 
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
    this.openPopup()
    this.loadDefinition()
  }

  // Open the popup modal
  openPopup() {
    this.popupTarget.style.display = 'block'
    this.backdropTarget.style.display = 'block'
    
    // Focus trap for accessibility
    this.frameTarget.focus()
  }

  // Close the popup modal
  close() {
    this.popupTarget.style.display = 'none'
    this.backdropTarget.style.display = 'none'
  }

  // Load Strong's definition using Turbo Frame
  loadDefinition() {
    // Use Turbo to load the content - no manual HTML building
    this.frameTarget.src = `/strongs/${this.strongNumberValue}`
  }

  // Close on backdrop click
  backdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  // Close on Escape key
  keydown(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}