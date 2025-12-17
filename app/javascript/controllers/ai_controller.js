import { Controller } from "@hotwired/stimulus"

// AI suggestions controller
export default class extends Controller {
  static targets = ["button", "result", "loading"]
  static values = {
    url: String,
    taskId: String,
    projectId: String,
    type: String
  }

  connect() {
    console.log("AI controller connected")
  }

  async generateSuggestion(event) {
    event.preventDefault()
    
    this.buttonTarget.disabled = true
    this.loadingTarget.classList.remove("hidden")
    this.resultTarget.classList.add("hidden")

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          task_id: this.taskIdValue,
          project_id: this.projectIdValue,
          suggestion_type: this.typeValue
        })
      })

      const data = await response.json()

      if (data.success) {
        this.resultTarget.innerHTML = `
          <div class="bg-green-50 border-l-4 border-green-400 p-4">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
              </div>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-green-800">AI Suggestion</h3>
                <div class="mt-2 text-sm text-green-700">
                  <pre class="whitespace-pre-wrap">${data.suggestion.content}</pre>
                </div>
              </div>
            </div>
          </div>
        `
        this.resultTarget.classList.remove("hidden")
      } else {
        this.showError(data.error || 'Failed to generate suggestion')
      }
    } catch (error) {
      this.showError('Network error: ' + error.message)
    } finally {
      this.loadingTarget.classList.add("hidden")
      this.buttonTarget.disabled = false
    }
  }

  showError(message) {
    this.resultTarget.innerHTML = `
      <div class="bg-red-50 border-l-4 border-red-400 p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <p class="text-sm text-red-700">${message}</p>
          </div>
        </div>
      </div>
    `
    this.resultTarget.classList.remove("hidden")
  }
}
