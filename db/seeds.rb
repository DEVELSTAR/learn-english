# Seed script for Learn English Web App
require "kramdown"
require "kramdown-parser-gfm"

puts "== Ensuring Super Admin User Exists =="
super_admin = User.find_or_initialize_by(email_address: "star@gmail.com")
super_admin.name = "Super Admin"
super_admin.password = "asdasd"
super_admin.password_confirmation = "asdasd"
super_admin.role = :super_admin
super_admin.save!
puts "Super Admin: #{super_admin.email_address} (ID: #{super_admin.id}, Role: #{super_admin.role})"
