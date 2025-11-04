class JobApplication < ApplicationRecord
  belongs_to :job
  belongs_to :jobseeker, class_name: 'User'
  has_one_attached :resume
  validates :about_yourself, presence: true, length: { minimum: 200, maximum: 1000 }
  validates :resume, presence: true
  validates :job_id,
    uniqueness: {
      scope: :jobseeker_id,
      message: "already applied"
    }, unless: :reapply_allowed
  validate :is_pdf

  private

  def is_pdf
    if resume.attached? && !resume.content_type.in?("application/pdf")
      errors.add(:resume, 'should be PDF!')
    end
  end
end
