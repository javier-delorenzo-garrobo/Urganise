class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = current_user.projects.active.order(created_at: :desc)
    @archived_projects = current_user.projects.archived.order(updated_at: :desc)
  end

  def show
    @tasks = @project.tasks.includes(:category).order(created_at: :desc)
    @categories = @project.categories
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    
    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully deleted."
  end

  def archive
    @project = current_user.projects.find(params[:id])
    @project.update(status: :archived)
    redirect_to projects_url, notice: "Project was archived."
  end

  def unarchive
    @project = current_user.projects.find(params[:id])
    @project.update(status: :active)
    redirect_to projects_url, notice: "Project was restored."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status)
  end
end
