class JobsController < ApplicationController
  before_action :ensure_recruiter!, except: [:view_job_description]
  before_action :set_job, only: %i[show edit update destroy]

  def index
    @recruiter_jobs = Job.where(recruiter_id: current_user.id)
  end

  def applicants
    @applications = JobApplication.joins(:job)
                                  .where(jobs: { recruiter_id: current_user.id })
                                  .includes(:job, :jobseeker)
                                  .order(created_at: :desc)
  end

  def recruiter_index; end

  def show; end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      users = User.where(role: 'jobseeker')
      users.find_each do |user|
        NotificationMailer.job_posted(user, @job).deliver_later
        Rails.logger.debug 'Email sent successfully!'
      rescue StandardError => e
        Rails.logger.debug { "Email failed: #{e.message}" }
      end
      flash[:success] = 'Job Posted successfully.'
      redirect_to recruiter_jobs_path
    else
      flash.now[:error] = @job.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def ai_description
    title = params[:title]
    
    if title.blank?
      return render json: { error: "Title is required" }, status: :unprocessable_entity
    end

    api_key = ENV['OPENAI_API_KEY']
    if api_key.blank?
      return render json: { error: "OpenAI API key is not configured" }, status: :internal_server_error
    end

    begin
      @client = OpenAI::Client.new(access_token: api_key)
      prompt = <<~PROMPT
        You are an expert HR content writer.
        Write a professional, detailed, and well-structured job description for the position: "#{title}".
        
        Follow this exact structure:
        If "#{title}" is not matching to any valid job title, please respond that it is not a valid job title and also do not add serial numbers like 1., 2., etc.
        
        Otherwise, structure the response as follows:
        1. Job Title  
        2. Location  
        3. Job Type  
        4. Department  
        5. Reports To  
        6. Company Overview  
        7. Position Overview  
        8. Key Responsibilities  
        9. Required Skills & Qualifications  
        10. Preferred Qualifications  
        11. What We Offer  

        The tone should be formal, confident, and employer-focused.
        Response:
      PROMPT

      response = @client.chat(
        parameters: {
          model: 'gpt-4o-mini',
          messages: [{ role: "user", content: prompt }],
          temperature: 0.2,
          max_tokens: 700
        }
      )

      jd = response.dig("choices", 0, "message", "content")&.strip
      
      if jd.blank?
        return render json: { error: "Failed to generate description. Please try again." }, status: :unprocessable_entity
      end

      render json: { description: jd }
    rescue StandardError => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "An error occurred while generating the description. Please try again later." }, status: :internal_server_error
    end
  end
  
  def view_job_description
    @job = Job.find_by(id: params[:job_id])
  end
  
  def edit; end

  def update
    if @job.update(job_params)
      flash[:success] = 'Job Updated successfully.'
      redirect_to recruiter_jobs_path
    else
      flash.now[:error] = @job.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    flash[:success] = 'Job Deleted successfully.'
    redirect_to recruiter_jobs_path
  end

  private

  def set_job
    @job = Job.find_by(id: params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :company_name, :location, :industry_type, :vacancy,
                                :experience_range, :salary, :work_mode, :employment_type, :role_category,
                                :education, :skills, :company_description)
  end

  def ensure_recruiter!
    redirect_to root_path, error: 'Access denied' unless current_user&.recruiter?
  end
end
