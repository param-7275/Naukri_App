# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  # around_action :switch_locale

  def switch_locale(&)
    locale = params[:locale] || extract_locale_from_tld || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def extract_locale_from_tld
    parsed_locale = request.host.split('.').last
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def not_found
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    flash[:error] = 'You must be logged in to access this section'
    redirect_to login_path
  end
end
