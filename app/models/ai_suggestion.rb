class AiSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :task, optional: true

  validates :suggestion_type, presence: true, inclusion: { in: %w[task_breakdown priority_recommendation time_estimate optimization] }
  validates :content, presence: true

  enum :suggestion_type, {
    task_breakdown: 0,
    priority_recommendation: 1,
    time_estimate: 2,
    optimization: 3
  }

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :by_type, ->(type) { where(suggestion_type: type) }
end
