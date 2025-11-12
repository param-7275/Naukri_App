import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "button"]

  async generateWithAI() {
    const title = this.titleTarget.value
    if (!title) {
      alert("Please enter a job title first!")
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "Generating..."

    const response = await fetch(`/generate_ai_description?title=${encodeURIComponent(title)}`)
    const data = await response.json()

    if (data.description) {
      this.descriptionTarget.value = data.description
    } else {
      alert("Error: could not generate description.")
    }

    this.buttonTarget.disabled = false
    this.buttonTarget.textContent = "Generate with AI"
  }
}
