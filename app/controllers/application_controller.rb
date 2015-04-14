class ApplicationController < ActionController::Base
  before_action :set_locale
  after_action :track_agent

  class UnauthorizedException < Exception
  end

  class ForbiddenException < Exception
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_page, :query_from_request

  # Get current user from session
  #
  # @return [User]
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) unless session[:user_id].nil?
  end

  # Get current page from request
  #
  # @return [Integer]
  def current_page
    @current_page ||= (params[:page] || 1).to_s.to_i
    @current_page = 1 unless @current_page > 0
    @current_page
  end

  def query_from_request
    @query_from_request ||= params[:query].to_s.encode('UTF-8', 'UTF-8', invalid: :replace, replace: '')
  end

  def default_url_options(options = {})
    if I18n.locale == I18n.default_locale
      { locale: nil }.merge options
    else
      { locale: I18n.locale }.merge options
    end
  end

  protected

  def set_locale
    locale_for_user = Language.locale_for_user current_user
    locale_from_params = params[:locale] # || http_accept_language.compatible_language_from(I18n.available_locales)
    I18n.locale = locale_from_params || locale_for_user || I18n.default_locale
  end

  def record_not_found
    ActiveRecord::RecordNotFound
  end

  def allow_authorized_only
    unless current_user
      flash[:notice] = t(:please_log_in)
      redirect_to login_path
    end
  end

  def demand_role(role)
    raise UnauthorizedException if current_user.nil? || !current_user.has_role?(role)
  end

  def suspect_spam?(user, text, tolerance = 1)
    if user.nil? || !user.decent?
      unless user.nil?
        tolerance += 1 if user.mail_confirmed?
        tolerance += 1 if user.entries_count > 10 && user.comments_count > 30
      end
      text.scan(/https?:\/\//).length >= tolerance
    else
      false
    end
  end

  def allow_administrators_only
    demand_role :administrator
  end

  # Get current user agent
  #
  # @return [Agent]
  def agent
    @agent ||= Agent.for_string(request.user_agent || 'n/a')
  end

  # Track request for current user agent
  def track_agent
    user_agent = agent
    user_agent.add_request if user_agent.is_a? Agent
  end

  def owner_for_entity
    if current_user && current_user.has_role?(:administrator)
      { owner_id: params[:owner_id], owner_type: params[:owner_type] }
    else
      { owner: current_user }
    end
  end

  def language_for_entity
    { language: Language.guess_from_locale }
  end

  def tracking_for_entity
    { agent: agent, ip: request.env['HTTP_X_REAL_IP'] || request.remote_ip }
  end
end
