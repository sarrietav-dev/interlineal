import { Controller } from "@hotwired/stimulus"

// Stimulus controller for search functionality
export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    // Auto-focus search input if it's empty
    if (this.hasInputTarget && !this.inputTarget.value) {
      this.inputTarget.focus()
    }
  }

  // Keyboard shortcuts for search
  keydown(event) {
    if ((event.ctrlKey || event.metaKey) && event.key === 'k') {
      event.preventDefault()
      this.focusSearch()
    }
  }

  // Focus and select search input
  focusSearch() {
    if (this.hasInputTarget) {
      this.inputTarget.focus()
      this.inputTarget.select()
    }
  }

  // Handle search form submission
  submit(event) {
    const query = this.inputTarget.value.trim()
    
    if (query.length < 2) {
      event.preventDefault()
      alert('Por favor, ingrese al menos 2 caracteres para buscar.')
      return false
    }
    
    // Let the form submit normally - no need for AJAX with Hotwire
    return true
  }
}