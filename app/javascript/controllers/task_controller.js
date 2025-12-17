import { Controller } from "@hotwired/stimulus"

// Task management controller for handling task actions
export default class extends Controller {
  static targets = ["checkbox", "status"]

  connect() {
    console.log("Task controller connected")
  }

  toggleComplete(event) {
    const taskId = event.currentTarget.dataset.taskId
    const projectId = event.currentTarget.dataset.projectId
    const isCompleted = event.currentTarget.dataset.completed === "true"
    
    const url = isCompleted 
      ? `/projects/${projectId}/tasks/${taskId}/uncomplete`
      : `/projects/${projectId}/tasks/${taskId}/complete`
    
    fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    }).then(response => {
      if (response.ok) {
        // Turbo will handle the response
        window.location.reload()
      }
    })
  }

  delete(event) {
    if (!confirm('Are you sure you want to delete this task?')) {
      event.preventDefault()
    }
  }
}
