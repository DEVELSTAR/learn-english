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

puts "\n== Ensuring Sample Community Notes Exist =="
if Note.none?
  sample_note = Note.new(user: super_admin, is_global: true)
  sample_note.content = <<~NOTE.strip
    1. Could you please give me a hand? — Kya aap meri thodi madad kar sakte hain?
    2. I'm on my way, will be there in ten minutes. — Main raaste mein hoon, 10 minute mein pahunchta hoon.
    3. It's completely up to you. — Yeh poori tarah aap par depend karta hai.
    4. Let me know when you are free. — Jab aap free ho toh mujhe bata dena.
    5. I didn't catch what you said. — Mujhe samajh nahi aaya aapne kya kaha.
    6. That makes a lot of sense. — Yeh baat bilkul sahi lagti hai.
    7. Can we reschedule our meeting? — Kya hum meeting ko kisi aur time rakh sakte hain?
    8. Don't worry, take your time. — Fikar mat karo, aaram se time lo.
    9. Keep up the good work! — Aise hi badhiya kaam karte raho!
    10. Let's wrap things up for today. — Chalo aaj ka kaam yahin khatam karte hain.
  NOTE
  sample_note.save!
  puts "Created sample global note: ID #{sample_note.id}"
end

puts "\n== Seeding Completed Successfully! =="
