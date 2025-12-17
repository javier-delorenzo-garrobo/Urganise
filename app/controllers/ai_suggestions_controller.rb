class AiSuggestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @suggestions = current_user.ai_suggestions.recent.includes(:task)
  end

  def create
    @task = current_user.tasks.find_by(id: params[:task_id]) if params[:task_id].present?
    
    service = GeminiService.new
    result = case params[:suggestion_type]
    when 'task_breakdown'
      service.generate_task_suggestions(@task.description)
    when 'priority_recommendation'
      service.suggest_task_priority(@task.title, @task.description, @task.due_date)
    when 'project_analysis'
      project = current_user.projects.find(params[:project_id])
      service.analyze_project(project.name, project.description, project.tasks.count)
    else
      { error: "Invalid suggestion type" }
    end

    if result[:success]
      @suggestion = current_user.ai_suggestions.create!(
        suggestion_type: params[:suggestion_type],
        content: result[:content],
        task: @task,
        metadata: result
      )
      
      render json: { success: true, suggestion: @suggestion }, status: :created
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end

  def destroy
    @suggestion = current_user.ai_suggestions.find(params[:id])
    @suggestion.destroy
    redirect_to ai_suggestions_path, notice: "Suggestion was deleted."
  end
end
