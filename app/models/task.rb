class Task < ApplicationRecord
  belongs_to :project
  belongs_to :category, optional: true
  belongs_to :user

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending in_progress completed] }
  validates :priority, presence: true, inclusion: { in: %w[low medium high urgent] }

  enum :status, { pending: 0, in_progress: 1, completed: 2 }, default: :pending
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }, default: :medium

  scope :pending, -> { where(status: :pending) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :completed, -> { where(status: :completed) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :due_soon, -> { where("due_date <= ?", 7.days.from_now).where(status: [:pending, :in_progress]) }
  scope :overdue, -> { where("due_date < ?", Date.today).where(status: [:pending, :in_progress]) }

  def overdue?
    due_date.present? && due_date < Date.today && !completed?
  end

  def completed?
    status == "completed"
  end
end
