class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :jobs, foreign_key: :recruiter_id, dependent: :destroy
  has_many :job_applications, foreign_key: :jobseeker_id, dependent: :destroy

  def recruiter?
    role == "recruiter"
  end

  def jobseeker?
    role == "jobseeker"
  end
end
