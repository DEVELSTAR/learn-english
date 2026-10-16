module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    before_action :require_authentication
    helper_method :authenticated?, :current_user, :admin?, :super_admin?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def current_user
      Current.user
    end

    def admin?
      Current.user&.admin?
    end

    def super_admin?
      Current.user&.super_admin?
    end

    def require_admin
      unless admin?
        redirect_to root_path, alert: "Access denied. Only the teacher can access this page."
      end
    end

    def require_super_admin
      unless super_admin?
        redirect_to admin_root_path, alert: "Access denied. Only Super Administrators can perform this action."
      end
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
