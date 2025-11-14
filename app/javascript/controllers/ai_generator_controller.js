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

    try {
      const response = await fetch(`/generate_ai_description?title=${encodeURIComponent(title)}`)
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({ error: "An error occurred" }))
        alert(errorData.error || `Error: ${response.status} ${response.statusText}`)
        this.buttonTarget.disabled = false
        this.buttonTarget.textContent = "Generate with AI"
        return
      }

      const data = await response.json()

      if (data.description) {
        this.descriptionTarget.value = data.description
      } else {
        alert(data.error || "Error: could not generate description.")
      }
    } catch (error) {
      console.error("Error generating AI description:", error)
      alert("Network error: Could not connect to the server. Please try again.")
    } finally {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "Generate with AI"
    }
  }
}
