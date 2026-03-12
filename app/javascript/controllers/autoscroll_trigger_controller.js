import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const container = this.element.closest("[data-controller='autoscroll']")
    if (container) {
      container.scrollTop = container.scrollHeight
    }
    this.element.remove()
  }
}
