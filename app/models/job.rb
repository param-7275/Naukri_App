class Job < ApplicationRecord
  belongs_to :recruiter, class_name: 'User'
  has_many :job_applications, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :vacancy, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :company_name, presence: true
  validates :location, presence: true
  validates :industry_type, presence: true
end
