# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :recruiter, class_name: 'User'
  has_many :job_applications, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :vacancy, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :company_name, presence: true
  validates :location, presence: true
  validates :industry_type, presence: true
  validates :experience_range, presence: true
  validates :work_mode, presence: true
  validates :employment_type, presence: true
  validates :role_category, presence: true
  validates :education, presence: true
  validates :skills, presence: true
  validates :company_description, presence: true
end
