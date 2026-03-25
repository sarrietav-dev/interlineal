import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "word_display_settings"

const DEFAULTS = {
  show_greek: true,
  show_hebrew: true,
  show_spanish: true,
  show_strongs: true,
  show_grammar: true,
  show_pronunciation: false,
  show_word_order: false
}

export default class extends Controller {
  connect() {
    this.applySettings(this.loadSettings())
    this.boundHandleUpdate = this.handleUpdate.bind(this)
    document.addEventListener("word-settings:updated", this.boundHandleUpdate)
  }

  disconnect() {
    document.removeEventListener("word-settings:updated", this.boundHandleUpdate)
  }

  handleUpdate(event) {
    this.applySettings(event.detail)
  }

  applySettings(settings) {
    const merged = { ...DEFAULTS, ...settings }
    this.element.querySelectorAll("[data-setting]").forEach(el => {
      el.hidden = merged[el.dataset.setting] === false
    })
  }

  loadSettings() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}")
    } catch {
      return {}
    }
  }

  static saveSettings(settings) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(settings))
  }
}
