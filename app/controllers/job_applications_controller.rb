class JobApplicationsController < ApplicationController
  before_action :ensure_jobseeker!
  before_action :set_job, only: [:new, :create]

  def applied_jobs
    @applications = current_user.job_applications.includes(:job).order(created_at: :desc)
  end

  def all_jobs
    @jobs = Job.all
  end

    
  def jobseeker_index
  end

  def new
    @job = Job.find_by(id: params[:job_id])
  end

  def create
    @application = @job.job_applications.build(jobseeker_id: current_user.id)
    
    if params[:resume].present?
      @application.resume.attach(params[:resume])
    end
  
    @application.about_yourself = params[:about_yourself]
    @application.status = "review"
    
    if @application.save
      redirect_to applied_jobs_path, notice: "Applied successfully."
    else
      flash.now[:alert] = @application.errors.full_messages.join(", ")
      render :new
    end
  end
  

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def job_application_params
    params.require(:job_application).permit(:resume, :about_yourself, :status)
  end

  def ensure_jobseeker!
    redirect_to root_path, alert: "Only jobseekers can perform that action" unless current_user&.jobseeker?
  end
end
