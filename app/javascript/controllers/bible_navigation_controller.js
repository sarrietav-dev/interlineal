import { Controller } from "@hotwired/stimulus"

// Stimulus controller for Bible navigation keyboard shortcuts
export default class extends Controller {
  static targets = ["prevLink", "nextLink", "slideshowLink"]
  
  connect() {
    // Auto-focus on verse reference for screen readers
    const verseReference = document.querySelector('.verse-reference')
    if (verseReference) {
      verseReference.focus()
    }
  }

  // Handle keyboard navigation
  keydown(event) {
    switch(event.key) {
      case 'ArrowLeft':
      case 'p':
      case 'P':
        event.preventDefault()
        this.navigatePrevious()
        break
      case 'ArrowRight':
      case 'n':
      case 'N':
        event.preventDefault()
        this.navigateNext()
        break
      case 'Escape':
        this.closePopups()
        break
      case 's':
      case 'S':
        if (event.ctrlKey || event.metaKey) {
          event.preventDefault()
          this.openSlideshow()
        }
        break
    }
  }

  navigatePrevious() {
    if (this.hasPrevLinkTarget) {
      this.prevLinkTarget.click()
    }
  }

  navigateNext() {
    if (this.hasNextLinkTarget) {
      this.nextLinkTarget.click()
    }
  }

  openSlideshow() {
    if (this.hasSlideshowLinkTarget) {
      window.open(this.slideshowLinkTarget.href, '_blank')
    }
  }

  closePopups() {
    // Dispatch custom event to close any open popups
    this.dispatch("closePopups")
  }
}