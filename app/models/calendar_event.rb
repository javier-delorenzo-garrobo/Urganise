class CalendarEvent < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  
  validates :title, presence: true, length: { maximum: 255 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validates :event_type, inclusion: { in: %w[meeting deadline task event reminder], allow_nil: true }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, allow_nil: true }
  
  # Scopes
  scope :upcoming, -> { where('start_time >= ?', Time.current).order(:start_time) }
  scope :past, -> { where('end_time < ?', Time.current).order(start_time: :desc) }
  scope :in_range, ->(start_date, end_date) { where('start_time <= ? AND end_time >= ?', end_date, start_date) }
  scope :by_type, ->(type) { where(event_type: type) }
  
  # Default values
  after_initialize :set_defaults, if: :new_record?
  
  def duration_minutes
    return 0 if start_time.nil? || end_time.nil?
    ((end_time - start_time) / 60).to_i
  end
  
  def overlaps_with?(other_event)
    return false if other_event.nil?
    (start_time < other_event.end_time) && (end_time > other_event.start_time)
  end
  
  private
  
  def set_defaults
    self.all_day ||= false
    self.event_type ||= 'event'
    self.color ||= '#3B82F6' # Blue
    self.attendees ||= []
  end
  
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
