ActiveAdmin.register User, as: "Administrator" do
  menu priority: 4, label: "Administrators", if: proc { current_user&.super_admin? }

  permit_params :name, :email_address, :role, :password, :password_confirmation

  config.clear_action_items!

  action_item :new, only: :index do
    link_to "New Administrator", new_admin_administrator_path
  end

  action_item :edit, only: :show, if: proc { resource.present? && !resource.super_admin? } do
    link_to "Edit Administrator", edit_admin_administrator_path(resource)
  end

  action_item :destroy, only: :show, if: proc { resource.present? && !resource.super_admin? } do
    link_to "Delete Administrator", admin_administrator_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this administrator?" }
  end

  controller do
    before_action :authorize_super_admin!

    def scoped_collection
      User.where(role: %i[admin super_admin])
    end

    def find_resource
      User.find(params[:id])
    end

    def show
      user = User.find_by(id: params[:id])
      if user&.student?
        redirect_to admin_administrators_path, alert: "User '#{user.name}' is a student, not an administrator." and return
      end
      super
    end

    def edit
      user = User.find_by(id: params[:id])
      if user&.super_admin?
        redirect_to admin_administrators_path, alert: "Super Administrator accounts cannot be modified from the admin panel." and return
      end
      if user&.student?
        redirect_to admin_administrators_path, alert: "User '#{user.name}' is a student, not an administrator." and return
      end
      super
    end

    def create
      build_resource
      if params[:user] && params[:user][:role] == "super_admin"
        resource.errors.add(:base, "Super Administrator accounts cannot be created from the admin panel.")
        flash.now[:alert] = "Super Administrator accounts cannot be created from the admin panel."
        render :new, status: :unprocessable_entity and return
      end

      # Only regular admin (teacher) accounts can be created from the admin panel
      resource.role = :admin

      super do |format|
        redirect_to admin_administrators_path, notice: "Administrator '#{resource.name}' was successfully created." and return if resource.valid?
      end
    end

    def update
      user = User.find_by(id: params[:id])
      if user&.super_admin?
        redirect_to admin_administrators_path, alert: "Super Administrator accounts cannot be modified from the admin panel." and return
      end
      if user&.student?
        redirect_to admin_administrators_path, alert: "User '#{user.name}' is a student, not an administrator." and return
      end

      # Disallow promoting anyone to super_admin from the admin panel
      if params[:user] && params[:user][:role] == "super_admin"
        params[:user][:role] = "admin"
      end

      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end

      super do |format|
        redirect_to admin_administrators_path, notice: "Administrator '#{resource.name}' was successfully updated." and return if resource.valid?
      end
    end

    def destroy
      target_admin = User.find_by(id: params[:id])
      if target_admin&.super_admin?
        redirect_to admin_administrators_path, alert: "Super Administrator accounts cannot be deleted from the admin panel!" and return
      end
      if target_admin == current_user
        redirect_to admin_administrators_path, alert: "You cannot delete your own account!" and return
      end

      super do |format|
        redirect_to admin_administrators_path, notice: "Administrator was successfully removed." and return
      end
    end

    private

    def authorize_super_admin!
      unless current_user&.super_admin?
        redirect_to admin_root_path, alert: "Access denied. Only Super Administrators can manage administrators."
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :email_address
    column :role do |admin|
      if admin.super_admin?
        status_tag "Super Admin", class: "error"
      else
        status_tag "Admin", class: "ok"
      end
    end
    column "Lessons Created" do |admin|
      admin.lessons.count
    end
    column "Created At", :created_at do |admin|
      admin.created_at.strftime("%B %d, %Y")
    end
    actions defaults: false do |admin|
      item "View", admin_administrator_path(admin), class: "member_link"
      unless admin.super_admin?
        item "Edit", edit_admin_administrator_path(admin), class: "member_link"
        item "Delete", admin_administrator_path(admin), method: :delete, data: { confirm: "Are you sure you want to delete this administrator?" }, class: "member_link"
      end
    end
  end

  filter :name
  filter :email_address
  filter :role, as: :select, collection: [["Admin", "admin"], ["Super Admin", "super_admin"]]
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs "Administrator Details" do
      f.input :name, placeholder: "e.g. John Doe"
      f.input :email_address, placeholder: "admin@learnenglish.com"
      f.input :role, as: :select, collection: [["Administrator (Teacher)", "admin"]], include_blank: false, hint: "Super Administrator accounts cannot be created or modified from the admin panel."
      f.input :password, hint: f.object.persisted? ? "Leave blank to keep existing password" : "Minimum 6 characters"
      f.input :password_confirmation
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email_address
      row :role do |admin|
        if admin.super_admin?
          div do
            status_tag "Super Admin", class: "error"
            span " (Protected: cannot be edited or deleted from the admin panel)", style: "color: #888; font-size: 11px; margin-left: 6px;"
          end
        else
          status_tag "Admin", class: "ok"
        end
      end
      row "Total Lessons Authored" do |admin|
        admin.lessons.count
      end
      row :created_at
      row :updated_at
    end

    panel "Lessons Authored by this Administrator" do
      lessons = administrator.lessons.order(lesson_date: :desc)
      if lessons.any?
        table_for lessons do
          column("Title") { |l| link_to l.title, admin_lesson_path(l) }
          column("Date") { |l| l.lesson_date.strftime("%B %d, %Y") if l.lesson_date }
          column("Status") { |l| status_tag l.status }
        end
      else
        div class: "blank_slate_container" do
          span "No lessons authored yet."
        end
      end
    end
  end
end
