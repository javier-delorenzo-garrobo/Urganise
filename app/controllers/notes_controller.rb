class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  
  def index
    @notes = current_user.notes.includes(:project).recent
    @projects = current_user.projects.active
  end
  
  def show
  end
  
  def new
    @note = current_user.notes.build
    @projects = current_user.projects.active
  end
  
  def create
    @note = current_user.notes.build(note_params)
    
    if @note.save
      redirect_to notes_path, notice: 'Note created successfully.'
    else
      @projects = current_user.projects.active
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @projects = current_user.projects.active
  end
  
  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: 'Note updated successfully.'
    else
      @projects = current_user.projects.active
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note.destroy
    redirect_to notes_path, notice: 'Note deleted successfully.'
  end
  
  private
  
  def set_note
    @note = current_user.notes.find(params[:id])
  end
  
  def note_params
    params.require(:note).permit(:title, :content, :color, :project_id, tags: [], files: [])
  end
end
