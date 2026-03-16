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
        console.log("Share toggled, shared:", shared)
        if (shared) {
          btn.classList.remove("social-card__publish-pill--unpublished")
          btn.classList.add("social-card__publish-pill--published")
          btn.closest(".social-card").classList.add("social-card--shared")
        } else {
          btn.classList.remove("social-card__publish-pill--published")
          btn.classList.add("social-card__publish-pill--unpublished")
          btn.closest(".social-card").classList.remove("social-card--shared")
        }
        btn.querySelector(".pill-label").textContent = shared ? "Published" : "Unpublished"
      })
      .catch(err => console.error("Share toggle failed:", err))
      .finally(() => { btn.disabled = false })
  }
}
