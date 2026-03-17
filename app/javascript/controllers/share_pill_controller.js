import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(e) {
    e.preventDefault()
    e.stopPropagation()

    const btn = this.element
    const url = btn.dataset.shareUrl
    console.log("Fetching:", url)
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    btn.disabled = true

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    })
      .then(r => {
        if (!r.ok) throw new Error("HTTP " + r.status)
        return r.json()
      })
      .then(({ shared }) => {
        btn.classList.toggle("social-card__publish-pill--published", shared)
        btn.classList.toggle("social-card__publish-pill--unpublished", !shared)
        btn.querySelector(".pill-label").textContent = shared ? "Published" : "Unpublished"
        btn.querySelector(".social-card__status-dot").style.background = shared ? "#1EDD88" : "#bbb"
      })
      .catch(err => console.error("Share toggle failed:", err))
      .finally(() => { btn.disabled = false })
  }
}
