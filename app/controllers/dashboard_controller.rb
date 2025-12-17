class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @projects = current_user.projects.active.limit(5)
    @recent_tasks = current_user.tasks.includes(:project, :category).order(created_at: :desc).limit(10)
    @pending_tasks = current_user.tasks.pending.includes(:project, :category).limit(5)
    @overdue_tasks = current_user.tasks.overdue.includes(:project, :category).limit(5)
    @due_soon_tasks = current_user.tasks.due_soon.includes(:project, :category).limit(5)
    
    @stats = {
      total_projects: current_user.projects.active.count,
      total_tasks: current_user.tasks.count,
      pending_tasks: current_user.tasks.pending.count,
      completed_tasks: current_user.tasks.completed.count,
      overdue_tasks: current_user.tasks.overdue.count
    }
  end
end
