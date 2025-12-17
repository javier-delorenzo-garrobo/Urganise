class Category < ApplicationRecord
  belongs_to :project
  has_many :tasks, dependent: :nullify

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  before_validation :set_default_color, on: :create

  private

  def set_default_color
    self.color ||= "#3B82F6" # Default blue color
  end
end
