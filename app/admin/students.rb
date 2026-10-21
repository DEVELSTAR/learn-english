ActiveAdmin.register User, as: "Student" do
  menu priority: 3, label: "Students"

  permit_params :name, :email_address, :password, :password_confirmation

  controller do
    def scoped_collection
      User.where(role: :student)
    end

    def find_resource
      User.find(params[:id])
    end

    def show
      user = User.find_by(id: params[:id])
      if user&.admin?
        redirect_to admin_students_path, alert: "User '#{user.name}' is an administrator, not a student." and return
      end
      super
    end

    def edit
      user = User.find_by(id: params[:id])
      if user&.admin?
        redirect_to admin_students_path, alert: "User '#{user.name}' is an administrator, not a student." and return
      end
      super
    end

    def create
      build_resource
      resource.role = :student
      super do |format|
        redirect_to admin_students_path, notice: "Student was successfully created." and return if resource.valid?
      end
    end

    def update
      user = User.find_by(id: params[:id])
      if user&.admin?
        redirect_to admin_students_path, alert: "User '#{user.name}' is an administrator, not a student." and return
      end

      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super do |format|
        redirect_to admin_students_path, notice: "Student was successfully updated." and return if resource.valid?
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :email_address
    column "Registered", :created_at do |student|
      student.created_at.strftime("%B %d, %Y")
    end
    column "Lessons Completed" do |student|
      status_tag "#{student.lesson_completions.where(completed: true).count} completed", class: "ok"
    end
    actions
  end

  filter :name
  filter :email_address
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs "Student Details" do
      f.input :name, placeholder: "e.g. Rahul Sharma"
      f.input :email_address, placeholder: "student@example.com"
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
      row :role do |student|
        status_tag student.role
      end
      row "Total Lessons Completed" do |student|
        student.lesson_completions.where(completed: true).count
      end
      row :created_at
      row :updated_at
    end

    panel "Completed Lessons" do
      completions = student.lesson_completions.where(completed: true).includes(:lesson)
      if completions.any?
        table_for completions do
          column("Lesson Title") { |c| link_to c.lesson.title, admin_lesson_path(c.lesson) }
          column("Class Date") { |c| c.lesson.lesson_date.strftime("%B %d, %Y") }
          column("Completed On") { |c| c.updated_at.strftime("%B %d, %Y at %I:%M %p") }
        end
      else
        div class: "blank_slate_container" do
          span "No completed lessons yet."
        end
      end
    end
  end
end
