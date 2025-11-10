# frozen_string_literal: true

class JobApplicationsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :require_login
  before_action :ensure_jobseeker!, only: %i[new create applied_jobs]
  before_action :ensure_recruiter!, only: [:change_application_status]
  before_action :set_job, only: %i[new create]
  before_action :set_job_application, only: [:change_application_status]

  def applied_jobs
    @applications = current_user.job_applications.includes(:job).order(created_at: :desc)
  end

  def all_jobs
    @jobs = if current_user&.is_premium? && current_user&.subscription.present?
              Job.order(created_at: :desc)
            else
              Job.where(created_at: ..7.days.ago).order(created_at: :desc)
            end
  end

  def view_employee_details
    @job_application = JobApplication.find_by(id: params[:id])
    @user_details = @job_application.jobseeker
    @job = @job_application.job
  end

  def jobseeker_index; end

  def new
    @job = Job.find_by(id: params[:job_id])
  end

  def plan_and_pricing
    @subscription = Subscription.find_by(user_id: current_user.id)
  end

  def edit_reapply
    @apply_job = JobApplication.find(params[:id])
    @job = @apply_job.job
  end

  def reapply_application
    old_application = current_user.job_applications.find(params[:id])
    unless old_application.reapply_allowed? && old_application.status == 'reject'
      redirect_to job_path(old_application.job_id), alert: "You can't reapply for this job yet."
      return
    end

    old_application.assign_attributes(
      about_yourself: params[:about_yourself],
      resume: params[:resume],
      status: 'review',
      reapply_allowed: false
    )

    if old_application.save
      redirect_to applied_jobs_path, notice: 'You have successfully reapplied!'
    else
      flash.now[:alert] = old_application.errors.full_messages.to_sentence
      render :edit_reapply, status: :unprocessable_entity
    end

    # job_id = old_application.job_id
    # about  = params[:about_yourself]
    # resume = params[:resume]

    # old_application.destroy!

    # new_application = JobApplication.new(
    #   job_id: job_id,
    #   jobseeker_id: current_user.id,
    #   about_yourself: about,
    #   resume: resume,
    #   status: 'review',
    #   reapply_allowed: false
    # )

    # if new_application.save
    #   redirect_to applied_jobs_path, notice: 'You have successfully reapplied!'
    # else
    #   flash.now[:alert] = new_application.errors.full_messages.to_sentence
    #   render :edit_reapply, status: :unprocessable_entity
    # end
  end

  def change_application_status # rubocop:disable Metrics/AbcSize
    @job_application = JobApplication.find_by(id: params[:id])

    if @job_application.present?
      if params[:job_application].present? && params[:job_application][:status].present?
        new_status = params[:job_application][:status]

        if new_status == 'reject'
          @job_application.update(
            status: new_status,
            rejected_at: Time.current,
            reapply_allowed: false
          )
        else
          @job_application.update(status: new_status)
        end

        redirect_to recruiter_applicants_path, notice: 'Status updated!'
      else
        redirect_to recruiter_applicants_path, alert: 'Invalid status parameter.'
      end
    else
      redirect_to recruiter_applicants_path, alert: 'Update failed.'
    end
  end

  def create # rubocop:disable Metrics/AbcSize
    @job = Job.find_by(id: params[:job_id])
    return redirect_to recruiter_applicants_path, alert: 'Job not found.' unless @job

    @job_application = current_user.job_applications.new(
      job_id: @job.id,
      status: 'review',
      about_yourself: params[:about_yourself],
      resume: params[:resume]
    )

    if @job_application.save
      flash[:success] = 'Application submitted!'
      redirect_to applied_jobs_path
    else
      flash.now[:error] = @job_application.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_job_application
    @job_application = JobApplication.find_by(id: params[:id])
  end

  def set_job
    @job = Job.find_by(id: params[:job_id])
  end

  def ensure_jobseeker!
    redirect_to root_path, alert: 'Only jobseekers can perform that action' unless current_user&.job_seeker?
  end

  def ensure_recruiter!
    redirect_to root_path, alert: 'Only recruiters can perform that action' unless current_user&.recruiter?
  end
end
