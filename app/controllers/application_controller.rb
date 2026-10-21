class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :ensure_admin_confined_to_admin_panel

  def authenticate_admin_user!
    require_authentication
    require_admin
  end

  private

  def ensure_admin_confined_to_admin_panel
    return unless authenticated? && current_user.regular_admin?
    return if request.path.start_with?("/admin")
    return if request.path.start_with?("/rails/active_storage")
    return if request.path == rails_health_check_path
    return if request.method == "DELETE" && request.path == session_path

    # Allow previewing individual lesson or topic in read-only mode from ActiveAdmin
    if request.get? && (previewing_lesson? || previewing_topic?)
      return
    end

    redirect_to admin_root_path, alert: "Administrators can only access the Admin Panel."
  end

  def previewing_lesson?
    controller_name == "lessons" && action_name == "show"
  end

  def previewing_topic?
    controller_name == "topics" && action_name == "show"
  end
end
