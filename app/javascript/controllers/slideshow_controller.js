import { Controller } from "@hotwired/stimulus"

// Stimulus controller for slideshow/presentation mode
export default class extends Controller {
  static targets = ["controls", "hints", "scrollIndicator", "scrollThumb"]
  
  connect() {
    this.controlsTimeout = null
    this.hintsTimeout = null
    this.cursorTimeout = null
    
    // Setup scroll indicator
    this.setupScrollIndicator()
    
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
    this.removeScrollListener()
  }

  // Setup scroll indicator and listener
  setupScrollIndicator() {
    const container = document.querySelector('.slideshow-container')
    if (!container) return

    // Add scroll event listener
    this.boundScrollHandler = this.handleScroll.bind(this)
    container.addEventListener('scroll', this.boundScrollHandler)
    
    // Initial scroll indicator update
    this.updateScrollIndicator()
  }

  // Remove scroll event listener
  removeScrollListener() {
    const container = document.querySelector('.slideshow-container')
    if (container && this.boundScrollHandler) {
      container.removeEventListener('scroll', this.boundScrollHandler)
    }
  }

  // Handle scroll events
  handleScroll() {
    this.updateScrollIndicator()
    
    // Show controls briefly when scrolling
    this.showControls()
    this.showScrollIndicator()
    this.clearTimeouts()
    
    this.controlsTimeout = setTimeout(() => {
      this.hideControls()
      this.hideScrollIndicator()
    }, 2000)
  }

  // Update scroll indicator position and visibility
  updateScrollIndicator() {
    const container = document.querySelector('.slideshow-container')
    if (!container || !this.hasScrollIndicatorTarget || !this.hasScrollThumbTarget) return
    
    const scrollHeight = container.scrollHeight
    const clientHeight = container.clientHeight
    const scrollTop = container.scrollTop
    
    // Only show scroll indicator if content is scrollable
    if (scrollHeight <= clientHeight) {
      this.hideScrollIndicator()
      return
    }
    
    // Calculate thumb position and size
    const scrollPercentage = scrollTop / (scrollHeight - clientHeight)
    const thumbHeight = Math.max(20, (clientHeight / scrollHeight) * 100) // Min 20% height
    const thumbPosition = scrollPercentage * (100 - thumbHeight)
    
    // Update thumb styles
    this.scrollThumbTarget.style.height = `${thumbHeight}%`
    this.scrollThumbTarget.style.transform = `translateY(${thumbPosition}%)`
  }

  // Show scroll indicator
  showScrollIndicator() {
    if (this.hasScrollIndicatorTarget) {
      this.scrollIndicatorTarget.classList.add('visible')
    }
  }

  // Hide scroll indicator
  hideScrollIndicator() {
    if (this.hasScrollIndicatorTarget) {
      this.scrollIndicatorTarget.classList.remove('visible')
    }
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

  // Enhanced keyboard navigation for slideshow with scroll controls
  keydown(event) {
    console.log('keydown', event)
    const prevLinks = document.querySelectorAll('[data-slideshow-nav="prev"]')
    const nextLinks = document.querySelectorAll('[data-slideshow-nav="next"]')
    const exitLinks = document.querySelectorAll('[data-slideshow-nav="exit"]')
    
    // Find the first enabled link
    const prevLink = Array.from(prevLinks).find(link => !link.disabled && link.href)
    const nextLink = Array.from(nextLinks).find(link => !link.disabled && link.href)
    const exitLink = Array.from(exitLinks).find(link => link.href)
    
    // Get the slideshow container for scrolling
    const container = document.querySelector('.slideshow-container')
    
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
      case 'ArrowUp':
        event.preventDefault()
        this.smoothScroll(container, 'up')
        break
      case 'ArrowDown':
      case ' ': // Spacebar
        event.preventDefault()
        this.smoothScroll(container, 'down')
        break
      case 'Home':
        event.preventDefault()
        this.scrollToTop(container)
        break
      case 'End':
        event.preventDefault()
        this.scrollToBottom(container)
        break
      case 'PageUp':
        event.preventDefault()
        this.smoothScroll(container, 'pageUp')
        break
      case 'PageDown':
        event.preventDefault()
        this.smoothScroll(container, 'pageDown')
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
      case '?':
      case 'h':
      case 'H':
        event.preventDefault()
        this.toggleHelp()
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

  // Smooth scroll functionality for long verses
  smoothScroll(container, direction) {
    if (!container) return
    
    const viewportHeight = window.innerHeight
    const scrollAmount = Math.floor(viewportHeight * 0.3) // 30% of viewport height
    const pageScrollAmount = Math.floor(viewportHeight * 0.8) // 80% of viewport height
    
    let targetScroll = container.scrollTop
    
    switch(direction) {
      case 'up':
        targetScroll -= scrollAmount
        break
      case 'down':
        targetScroll += scrollAmount
        break
      case 'pageUp':
        targetScroll -= pageScrollAmount
        break
      case 'pageDown':
        targetScroll += pageScrollAmount
        break
    }
    
    // Ensure scroll position is within bounds
    targetScroll = Math.max(0, Math.min(targetScroll, container.scrollHeight - container.clientHeight))
    
    container.scrollTo({
      top: targetScroll,
      behavior: 'smooth'
    })
    
    // Show controls briefly when scrolling
    this.showControls()
    this.showScrollIndicator()
    this.clearTimeouts()
    this.controlsTimeout = setTimeout(() => {
      this.hideControls()
      this.hideScrollIndicator()
    }, 2000)
    
    // Update scroll indicator after animation completes
    setTimeout(() => {
      this.updateScrollIndicator()
    }, 500)
  }

  // Scroll to top of content
  scrollToTop(container) {
    if (!container) return
    
    container.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
    
    this.showControls()
    this.showScrollIndicator()
    this.clearTimeouts()
    this.controlsTimeout = setTimeout(() => {
      this.hideControls()
      this.hideScrollIndicator()
    }, 2000)
    
    // Update scroll indicator after animation completes
    setTimeout(() => {
      this.updateScrollIndicator()
    }, 500)
  }

  // Scroll to bottom of content
  scrollToBottom(container) {
    if (!container) return
    
    container.scrollTo({
      top: container.scrollHeight,
      behavior: 'smooth'
    })
    
    this.showControls()
    this.showScrollIndicator()
    this.clearTimeouts()
    this.controlsTimeout = setTimeout(() => {
      this.hideControls()
      this.hideScrollIndicator()
    }, 2000)
    
    // Update scroll indicator after animation completes
    setTimeout(() => {
      this.updateScrollIndicator()
    }, 500)
  }

  // Toggle help/keyboard shortcuts display
  toggleHelp() {
    let helpModal = document.getElementById('keyboard-help-modal')
    
    if (!helpModal) {
      this.createHelpModal()
      helpModal = document.getElementById('keyboard-help-modal')
    }
    
    const isVisible = helpModal.style.display === 'block'
    helpModal.style.display = isVisible ? 'none' : 'block'
    
    if (!isVisible) {
      // Auto-hide after 10 seconds
      setTimeout(() => {
        if (helpModal.style.display === 'block') {
          helpModal.style.display = 'none'
        }
      }, 10000)
    }
  }

  // Create keyboard shortcuts help modal
  createHelpModal() {
    const modal = document.createElement('div')
    modal.id = 'keyboard-help-modal'
    modal.innerHTML = `
      <div style="
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(31, 41, 55, 0.95);
        backdrop-filter: blur(10px);
        border: 2px solid rgba(59, 130, 246, 0.5);
        border-radius: 1rem;
        padding: 2rem;
        color: white;
        font-family: 'Segoe UI', sans-serif;
        z-index: 1000;
        max-width: 90vw;
        max-height: 90vh;
        overflow-y: auto;
        display: none;
      ">
        <h2 style="color: #fbbf24; margin-bottom: 1.5rem; font-size: clamp(1.5rem, 4vw, 2.5rem); text-align: center;">
          Keyboard Shortcuts
        </h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; font-size: clamp(0.875rem, 2vw, 1.25rem);">
          <div>
            <h3 style="color: #60a5fa; margin-bottom: 0.75rem;">Navigation</h3>
            <div><strong>←</strong> or <strong>P</strong> - Previous Verse</div>
            <div><strong>→</strong> or <strong>N</strong> - Next Verse</div>
            <div><strong>Esc</strong> - Exit Slideshow</div>
          </div>
          <div>
            <h3 style="color: #60a5fa; margin-bottom: 0.75rem;">Scrolling</h3>
            <div><strong>↑</strong> - Scroll Up</div>
            <div><strong>↓</strong> or <strong>Space</strong> - Scroll Down</div>
            <div><strong>Page Up</strong> - Large Scroll Up</div>
            <div><strong>Page Down</strong> - Large Scroll Down</div>
            <div><strong>Home</strong> - Go to Top</div>
            <div><strong>End</strong> - Go to Bottom</div>
          </div>
          <div>
            <h3 style="color: #60a5fa; margin-bottom: 0.75rem;">Display</h3>
            <div><strong>F</strong> or <strong>F11</strong> - Toggle Fullscreen</div>
            <div><strong>?</strong> or <strong>H</strong> - Show/Hide Help</div>
          </div>
        </div>
        <div style="text-align: center; margin-top: 1.5rem; color: #9ca3af; font-size: clamp(0.75rem, 1.5vw, 1rem);">
          Press <strong>?</strong> or <strong>H</strong> again to hide this help
        </div>
      </div>
    `
    
    document.body.appendChild(modal)
    
    // Close on click outside
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.style.display = 'none'
      }
    })
  }
}