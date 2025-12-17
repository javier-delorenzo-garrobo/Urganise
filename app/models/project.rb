class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :calendar_events, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[active archived completed] }

  enum :status, { active: 0, archived: 1, completed: 2 }, default: :active

  scope :active, -> { where(status: :active) }
  scope :archived, -> { where(status: :archived) }
  scope :completed, -> { where(status: :completed) }
end
