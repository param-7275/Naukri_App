class ApplicationController < ActionController::Base
  # Make current_user available in views
  helper_method :current_user, :logged_in?

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || extract_locale_from_tld || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
  
  def extract_locale_from_tld
    parsed_locale = request.host.split(".").last
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end
  
  private

  # Returns the currently logged-in user (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if a user is logged in
  def logged_in?
    current_user.present?
  end

  # Redirects to login page if not logged in
  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
end

