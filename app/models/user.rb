# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :subscription, dependent: :destroy
  has_many :jobs, foreign_key: :recruiter_id, dependent: :destroy
  has_many :job_applications, foreign_key: :jobseeker_id, dependent: :destroy

  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true
  validates :phone_number,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{10}\z/, message: I18n.t('users.signup.number_validation_message') }
  validates :role, presence: true

  enum :role, { job_seeker: 'jobseeker', recruiter: 'recruiter' }

  validates :password, presence: true, length: { minimum: 8 }, format:
    {
      with: /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])/,
      message: I18n.t('users.signup.password_validation_message')
      # message: "must include at least one letter, one number, and one special character (!@\#$%^&*)"
    }, if: :password
end
