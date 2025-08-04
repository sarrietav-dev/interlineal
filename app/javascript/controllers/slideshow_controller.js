import { Controller } from "@hotwired/stimulus"

// Stimulus controller for slideshow/presentation mode
export default class extends Controller {
  static targets = ["controls", "hints"]
  
  connect() {
    this.controlsTimeout = null
    this.hintsTimeout = null
    this.cursorTimeout = null
    
    // Show initial hint
    setTimeout(() => {
      this.showHints()
      setTimeout(() => {
        this.hideHints()
      }, 5000)
    }, 1000)
    
    this.showCursor()
  }

  disconnect() {
    this.clearTimeouts()
  }

  // Show controls on mouse movement
  mousemove() {
    console.log('mousemove')
    this.showControls()
    this.showHints()
    this.showCursor()
    
    this.clearTimeouts()
    
    this.controlsTimeout = setTimeout(() => {
      this.hideControls()
    }, 3000)
    
    this.hintsTimeout = setTimeout(() => {
      this.hideHints()
    }, 5000)
  }

  // Keyboard navigation for slideshow
  keydown(event) {
    console.log('keydown', event)
    const prevLinks = document.querySelectorAll('[data-slideshow-nav="prev"]')
    const nextLinks = document.querySelectorAll('[data-slideshow-nav="next"]')
    const exitLinks = document.querySelectorAll('[data-slideshow-nav="exit"]')
    
    // Find the first enabled link
    const prevLink = Array.from(prevLinks).find(link => !link.disabled && link.href)
    const nextLink = Array.from(nextLinks).find(link => !link.disabled && link.href)
    const exitLink = Array.from(exitLinks).find(link => link.href)
    
    switch(event.key) {
      case 'ArrowLeft':
      case 'p':
      case 'P':
        event.preventDefault()
        if (prevLink) {
          window.location.href = prevLink.href
        }
        break
      case 'ArrowRight':
      case 'n':
      case 'N':
        event.preventDefault()
        if (nextLink) {
          window.location.href = nextLink.href
        }
        break
      case 'Escape':
        event.preventDefault()
        if (exitLink) {
          window.location.href = exitLink.href
        }
        break
      case 'f':
      case 'F':
      case 'F11':
        event.preventDefault()
        this.toggleFullscreen()
        break
    }
  }

  // Toggle fullscreen mode
  toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(err => {
        console.log(`Error enabling fullscreen: ${err.message}`)
      })
    } else {
      document.exitFullscreen()
    }
  }

  // Show controls
  showControls() {
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.add('visible')
    }
  }

  // Hide controls
  hideControls() {
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.remove('visible')
    }
  }

  // Show hints
  showHints() {
    if (this.hasHintsTarget) {
      this.hintsTarget.classList.add('visible')
    }
  }

  // Hide hints
  hideHints() {
    if (this.hasHintsTarget) {
      this.hintsTarget.classList.remove('visible')
    }
  }

  // Show cursor
  showCursor() {
    document.body.style.cursor = 'default'
    clearTimeout(this.cursorTimeout)
    this.cursorTimeout = setTimeout(() => {
      document.body.style.cursor = 'none'
    }, 3000)
  }

  // Clear all timeouts
  clearTimeouts() {
    clearTimeout(this.controlsTimeout)
    clearTimeout(this.hintsTimeout)
    clearTimeout(this.cursorTimeout)
  }
}