class Note < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  
  # Active Storage for file attachments
  has_many_attached :files
  
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, length: { maximum: 10000 }
  validates :color, inclusion: { in: %w[yellow blue green pink purple orange gray], allow_nil: true }
  validate :acceptable_files
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_project, ->(project_id) { where(project_id: project_id) }
  scope :with_attachments, -> { joins(:files_attachments) }
  
  # Default values
  after_initialize :set_defaults, if: :new_record?
  
  private
  
  def set_defaults
    self.color ||= 'yellow'
    self.tags ||= []
    self.attachments ||= []
  end
  
  def acceptable_files
    return unless files.attached?
    
    files.each do |file|
      unless file.byte_size <= 10.megabytes
        errors.add(:files, "File #{file.filename} is too big (max 10MB)")
      end
      
      acceptable_types = %w[image/jpeg image/png image/gif application/pdf 
                           application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                           application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                           text/plain]
      unless acceptable_types.include?(file.content_type)
        errors.add(:files, "File #{file.filename} must be a JPG, PNG, GIF, PDF, DOC, DOCX, XLS, XLSX, or TXT")
      end
    end
  end
end
