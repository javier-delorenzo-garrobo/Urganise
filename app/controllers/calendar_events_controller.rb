class CalendarEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_calendar_event, only: [:show, :edit, :update, :destroy]
  
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    start_date = @date.beginning_of_month.beginning_of_week
    end_date = @date.end_of_month.end_of_week
    
    @calendar_events = current_user.calendar_events
                                   .includes(:project)
                                   .in_range(start_date, end_date)
                                   .order(:start_time)
    @projects = current_user.projects.active
  end
  
  def show
  end
  
  def new
    @calendar_event = current_user.calendar_events.build
    @projects = current_user.projects.active
    
    # Pre-fill with date if provided
    if params[:date]
      date = Date.parse(params[:date])
      @calendar_event.start_time = date.to_time + 9.hours # 9 AM default
      @calendar_event.end_time = date.to_time + 10.hours # 1 hour duration
    end
  end
  
  def create
    @calendar_event = current_user.calendar_events.build(calendar_event_params)
    
    if @calendar_event.save
      redirect_to calendar_events_path, notice: 'Event created successfully.'
    else
      @projects = current_user.projects.active
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @projects = current_user.projects.active
  end
  
  def update
    if @calendar_event.update(calendar_event_params)
      redirect_to calendar_events_path, notice: 'Event updated successfully.'
    else
      @projects = current_user.projects.active
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @calendar_event.destroy
    redirect_to calendar_events_path, notice: 'Event deleted successfully.'
  end
  
  private
  
  def set_calendar_event
    @calendar_event = current_user.calendar_events.find(params[:id])
  end
  
  def calendar_event_params
    params.require(:calendar_event).permit(
      :title, :description, :start_time, :end_time, :all_day,
      :event_type, :color, :location, :reminder_minutes,
      :recurrence_rule, :project_id, attendees: []
    )
  end
end
