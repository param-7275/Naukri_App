class JobsController < ApplicationController
  before_action :ensure_recruiter!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @recruiter_jobs = Job.where(recruiter_id: current_user.id)
  end

  def applicants
    @applications = JobApplication.joins(:job)
          .where(jobs: { recruiter_id: current_user.id })
          .includes(:job, :jobseeker)
          .order(created_at: :desc)
  end
    
  def recruiter_index
  end

  def show
  end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      flash[:success] = "Job Posted successfully."
      redirect_to recruiter_jobs_path
    else
      flash.now[:error] = @job.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def view_job_description
    @job = Job.find_by(id: params[:job_id])
  end

  def edit; end

  def update
    if @job.update(job_params)
      flash[:success] = "Job Updated successfully."
      redirect_to recruiter_jobs_path
    else
      flash.now[:error] = @job.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    flash[:success] = "Job Deleted successfully."
    redirect_to recruiter_jobs_path
  end

  private

  def set_job
    @job = Job.find_by(id: params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :company_name, :location, :industry_type, :vacancy)
  end

  def ensure_recruiter!
    redirect_to root_path, alert: "Access denied" unless current_user&.recruiter?
  end
end
