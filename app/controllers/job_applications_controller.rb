class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_jobseeker!
  before_action :set_job, only: [:new, :create]

  def index
    # My applied jobs
    @applications = current_user.job_applications.includes(:job).order(created_at: :desc)
  end

  def new
    @application = @job.job_applications.build
  end

  def create
    @application = @job.job_applications.build(jobseeker: current_user)
    @application.resume.attach(params[:job_application][:resume]) if params[:job_application][:resume].present?
    @application.status = "applied"
    if @application.save
      redirect_to job_applications_path, notice: "Applied successfully."
    else
      flash.now[:alert] = @application.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def ensure_jobseeker!
    redirect_to root_path, alert: "Only jobseekers can perform that action" unless current_user&.jobseeker?
  end
end
