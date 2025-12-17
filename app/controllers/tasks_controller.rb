class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :uncomplete]

  def index
    @tasks = @project.tasks.includes(:category).order(created_at: :desc)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(priority: params[:priority]) if params[:priority].present?
  end

  def show
  end

  def new
    @task = @project.tasks.build(user: current_user)
    @categories = @project.categories
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.user = current_user
    
    if @task.save
      redirect_to project_task_path(@project, @task), notice: "Task was successfully created."
    else
      @categories = @project.categories
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = @project.categories
  end

  def update
    if @task.update(task_params)
      redirect_to project_task_path(@project, @task), notice: "Task was successfully updated."
    else
      @categories = @project.categories
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_tasks_url(@project), notice: "Task was successfully deleted."
  end

  def complete
    @task.update(status: :completed, completed_at: Time.current)
    redirect_to project_path(@project), notice: "Task marked as completed."
  end

  def uncomplete
    @task.update(status: :pending, completed_at: nil)
    redirect_to project_path(@project), notice: "Task marked as pending."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :category_id)
  end
end
