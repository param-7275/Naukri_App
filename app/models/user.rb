class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :jobs, foreign_key: :recruiter_id, dependent: :destroy
  has_many :job_applications, foreign_key: :jobseeker_id, dependent: :destroy
  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true
  validates :phone_number, uniqueness: true, presence: true
  validates :role, presence: true
  enum role: { jobseeker: "jobseeker", recruiter: "recruiter" }
end
