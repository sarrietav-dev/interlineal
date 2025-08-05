import { Controller } from "@hotwired/stimulus";

// Minimal Stimulus controller for modal behavior
export default class extends Controller {
  static targets = ["backdrop"];
  
  connect() {
    // Focus trap for accessibility
    this.element.focus();

    // Add event listener for Escape key
    this.boundEscapeHandler = this.handleEscape.bind(this);
    document.addEventListener("keydown", this.boundEscapeHandler);
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener("keydown", this.boundEscapeHandler);
  }

  // Close modal on Escape key
  handleEscape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  // Close modal on outside click
  closeOnOutside(event) {
    if (event.target === this.element) {
      this.close();
    }
  }

  // Close modal (remove turbo frame content)
  close() {
    const frame = this.element.closest("turbo-frame");
    if (frame) {
      // Dispatch a custom event that can be handled by Turbo
      const event = new CustomEvent("modal:close", { bubbles: true });
      frame.dispatchEvent(event);
      
      // Clear the frame content
      frame.innerHTML = "";
    }
  }
}
