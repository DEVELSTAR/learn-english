# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Platform Statistics" do
          ul do
            li do
              strong "Total Registered Students: "
              span User.where(role: :student).count
            end
            li do
              strong "Published Lessons: "
              span Lesson.published.count
            end
            li do
              strong "Draft Lessons: "
              span Lesson.draft.count
            end
            li do
              strong "Shared Word Lists: "
              span WordList.created_by_admin.count
            end
          end
        end
      end
    end

    columns do
      column do
        panel "Recent Lessons" do
          recent_lessons = Lesson.order(lesson_date: :desc).limit(5)
          if recent_lessons.any?
            table_for recent_lessons do
              column("Title") { |l| link_to l.title, admin_lesson_path(l) }
              column("Date") { |l| l.lesson_date.strftime("%B %d, %Y") if l.lesson_date }
              column("Status") { |l| status_tag l.status }
            end
          else
            div class: "blank_slate_container" do
              span "No lessons created yet."
            end
          end
        end
      end

      column do
        panel "Recent Students" do
          recent_students = User.where(role: :student).order(created_at: :desc).limit(5)
          if recent_students.any?
            table_for recent_students do
              column("Name") { |s| link_to s.name, admin_student_path(s) }
              column("Email") { |s| s.email_address }
              column("Registered") { |s| s.created_at.strftime("%B %d, %Y") }
            end
          else
            div class: "blank_slate_container" do
              span "No students registered yet."
            end
          end
        end
      end
    end
  end
end
