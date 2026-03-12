import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sentences = ["Tell us more about your idea...", "What problem does it solve?", "Who is your target audience?"]
    this.index = 0
    this.char = 0
    this.deleting = false
    this.tick()
  }

  disconnect() { clearTimeout(this.timer) }

  tick() {
    const word = this.sentences[this.index]
    this.deleting ? this.char-- : this.char++
    this.element.setAttribute("placeholder", word.slice(0, this.char))

    if (!this.deleting && this.char === word.length) {
      this.timer = setTimeout(() => { this.deleting = true; this.tick() }, 2000)
    } else if (this.deleting && this.char === 0) {
      this.deleting = false
      this.index = (this.index + 1) % this.sentences.length
      this.timer = setTimeout(() => this.tick(), 400)
    } else {
      this.timer = setTimeout(() => this.tick(), this.deleting ? 25 : 45)
    }
  }
}
