class Job < ApplicationRecord
  belongs_to :recruiter, class_name: 'User'
  has_many :job_applications, dependent: :destroy
end
