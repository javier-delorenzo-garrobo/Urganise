class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = @project.categories.order(:name)
  end

  def new
    @category = @project.categories.build
  end

  def create
    @category = @project.categories.build(category_params)
    
    if @category.save
      redirect_to project_categories_path(@project), notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to project_categories_path(@project), notice: "Category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to project_categories_url(@project), notice: "Category was successfully deleted."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_category
    @category = @project.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
