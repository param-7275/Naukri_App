class JobApplication < ApplicationRecord
  belongs_to :job
  belongs_to :jobseeker, class_name: 'User'
  has_rich_text :about_yourself
  has_one_attached :resume
  validates :about_yourself, presence: true
  validates :job_id, uniqueness: { scope: :jobseeker_id, message: "already applied" }
end
