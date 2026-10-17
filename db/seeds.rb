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

classes_data = [
  {
    title: "Daily Life English",
    date: Date.new(2026, 10, 9),
    markdown: <<~MD
      ### 1. What did you eat for lunch?

      **Meaning:** Tumne lunch mein kya khaya?

      - Biryani. — Biryani.
      - Just biryani. — Bas biryani.
      - I had biryani. — Maine biryani khayi.
      - Just some biryani. — Bas thodi biryani.
      - I ate biryani today. — Maine aaj biryani khayi.
      - I actually haven't had lunch yet. — Maine abhi tak lunch nahi kiya hai.
      - I skipped lunch today. — Maine aaj lunch nahi kiya.
      - I just had a snack instead of a proper lunch. — Maine proper lunch ki jagah halka-phulka kuchh khaya.

      ---

      ### 2. Phone katne ke baad main sabji lene jaungi

      - **As soon as you get off the phone, I'll grab some vegetables.** — Jaise hi tumhara phone khatam hoga, main sabji lene jaungi.
      - **Once you hang up the phone, I'll go buy vegetables.** — Tumhare phone rakhne ke baad main sabji lene jaungi.

      **Useful phrases:**
      - Hang up the phone — Phone rakhna.
      - Get off the phone — Phone par baat khatam karna.

      ---

      ### 3. Asking the price

      - How much? — Kitne ka?
      - How much is this? — Ye kitne ka hai?
      - What's the price? — Iska daam kya hai?
      - How much for this one? — Ye wala kitne ka hai?
      - How much is the 10 kg bag? — 10 kilo wala bag kitne ka hai?
      - What does this cost? — Iski keemat kya hai?
      - Could you tell me the price of this, please? — Kya aap mujhe iska daam bata sakte hain?

      ---

      ### 4. “Aur batao” in English

      - What's up with you? — Kya chal raha hai?
      - Anything new on your end? — Tumhari taraf kuchh naya?
      - What's going on in your life? — Tumhari life mein kya chal raha hai?
      - How's everything else? — Baaki sab kaisa hai?
      - What else is new? — Aur kya naya hai?
    MD
  },
  {
    title: "As Soon As vs Once & Grab vs Buy vs Purchase",
    date: Date.new(2026, 10, 12),
    markdown: <<~MD
      ### 1. As soon as vs Once

      **As soon as** — Jaise hi, turant action lene par focus.

      **Example:** As soon as you get off the phone, I'll grab some vegetables.  
      **Meaning:** Jaise hi tumhara phone khatam hoga, main sabji lene jaungi.

      **Once** — Jab ek kaam poora ho jaaye, uske baad doosra kaam hoga.

      **Example:** Once you get off the phone, I'll grab some vegetables.  
      **Meaning:** Tumhara phone khatam hone ke baad main sabji lene jaungi.

      **Yaad rakho:** Dono sentences sahi hain. “As soon as” mein turant action par zyada focus hai, jabki “once” mein pehle ek kaam poora hone par.

      ---

      ### 2. Grab vs Buy vs Purchase

      **Grab** — Jaldi se ya casually kuchh le lena.  
      *Example:* I'll grab some vegetables.  
      *Meaning:* Main jaldi se kuchh sabji le aaungi.

      **Buy** — Khareedna. Daily English mein sabse common word.  
      *Example:* I need to buy some vegetables.  
      *Meaning:* Mujhe kuchh sabji khareedni hai.

      **Purchase** — Khareedna, lekin thoda formal tareeka.  
      *Example:* I purchased a new laptop.  
      *Meaning:* Maine ek naya laptop khareeda.

      **Yaad rakho:**
      - Daily conversation mein **buy** use karo.
      - Jaldi se kuchh lene ja rahe ho, toh **grab** use kar sakte ho.
      - Formal situations mein **purchase** use kar sakte ho.
    MD
  },
  {
    title: "Revision & Vocabulary for Success",
    date: Date.new(2026, 10, 13),
    markdown: <<~MD
      ### 1. Quick Revision

      - What did you have for lunch? — Tumne lunch mein kya khaya?
      - I had biryani. — Maine biryani khayi.
      - Hang up the phone. — Phone rakh do.
      - As soon as / Once — Jaise hi / Uske baad.
      - How much is this? — Ye kitne ka hai?
      - What's the price? — Iska daam kya hai?
      - What else is new? — Aur kya naya hai?
      - I'm leaving. — Main chalta hoon.
      - I've got to go. — Mujhe ab jaana hoga.

      ---

      ### 2. Vocabulary

      - **Dream** — Sapna
      - **Goal** — Lakshya
      - **Destination** — Manzil
      - **Planning** — Yojana banana
      - **Target** — Lakshya
      - **Execution** — Plan par kaam karna
      - **Hard work** — Mehnat
      - **Discipline** — Anushasan
      - **Focused** — Dhyan lagaye hue
      - **Procrastination** — Kaam ko taalna
      - **Delay** — Deri
      - **Result / Outcome** — Nateeja
      - **Focus** — Dhyan
      - **Consistency** — Lagataar mehnat karna
      - **Inconsistency** — Regular na rehna

      ---

      ### 3. Useful Sentences

      - **Consistency beats everything.** — Lagataar mehnat karna bahut maayne rakhta hai.
      - **Hard work and smart work are both important.** — Mehnat aur samajhdari se kaam karna, dono zaroori hain.
      - **If not now, then when?** — Agar abhi nahi, toh phir kab?
      - **Challenge yourself.** — Khud ko challenge do.
      - **The first and most important thing is to stay focused.** — Sabse zaroori baat hai apne goal par dhyan dena.
      - **Write down all the sentences you use in your daily life.** — Apni daily life mein bole jaane wale sentences likho.

      ---

      ### 4. Discipline: The Odysseus Rule

      Jab tumhe pata ho ki koi cheez tumhe distract kar sakti hai, toh pehle se apne liye rules bana lo.

      **Jaise:**
      - Padhai ke waqt phone door rakhna.
      - Social media ke liye time limit set karna.
      - Apne plan ke according kaam karna, mood ka wait nahi karna.
    MD
  },
  {
    title: "Daily Use Vocabulary",
    date: Date.new(2026, 10, 14),
    markdown: <<~MD
      ### 1. Dive deep into it

      **Meaning:** Kisi cheez ko gehrai se samajhna.  
      *Example:* I want to dive deep into this topic.  
      *Meaning:* Main is topic ko achhe se samajhna chahta hoon.

      ---

      ### 2. Dip / Bottom

      - **Dip** — Girawat aana.
      - **Bottom** — Sabse neeche ka hissa.

      *Example:* Sales took a dip this month.  
      *Meaning:* Is mahine sales mein girawat aayi.

      ---

      ### 3. Peak / Top

      - **Peak** — Sabse ooncha level.
      - **Top** — Sabse upar.

      *Example:* He is at the peak of his career.  
      *Meaning:* Woh apne career ke sabse achhe level par hai.

      ---

      ### 4. Hectic day / Busy day

      **Meaning:** Bahut zyada kaam wala din.  
      *Example:* I had a hectic day today.  
      *Meaning:* Aaj mera din bahut busy tha.

      ---

      ### 5. Drained

      **Meaning:** Bahut thak jaana ya energy khatam ho jaana.  
      *Example:* I'm completely drained after work.  
      *Meaning:* Kaam ke baad main bilkul thak gaya hoon.

      ---

      ### 6. Take a toll

      **Meaning:** Kisi cheez ka bura asar padna.  
      *Example:* Working long hours has taken a toll on my health.  
      *Meaning:* Lambe samay tak kaam karne ka meri sehat par bura asar pada hai.

      ---

      ### 7. Survival

      **Meaning:** Zinda rehna ya mushkil situation mein tikke rehna.  
      *Example:* Survival is difficult without food and water.  
      *Meaning:* Khane aur paani ke bina zinda rehna mushkil hai.

      ---

      ### 8. Double down

      **Meaning:** Kisi goal ke liye aur zyada effort lagana.  
      *Example:* I need to double down on my studies.  
      *Meaning:* Mujhe apni padhai mein aur zyada mehnat karni hai.
    MD
  },
  {
    title: "Requirements, Comparison & Similarities",
    date: Date.new(2026, 10, 15),
    markdown: <<~MD
      ### 1. Compulsory / Required

      **Meaning:** Zaroori.

      - Attendance is compulsory. — Attendance zaroori hai.
      - This document is required. — Ye document zaroori hai.

      ---

      ### 2. Requirement

      **Meaning:** Zaroorat ya aavashyakta.  
      *Example:* What are the requirements for this job?  
      *Meaning:* Is job ke liye kya-kya zaroori hai?

      ---

      ### 3. Prior knowledge

      **Meaning:** Pehle se kisi cheez ki jaankari hona.  
      *Example:* You need some prior knowledge of English.  
      *Meaning:* Tumhe English ki pehle se thodi jaankari honi chahiye.

      ---

      ### 4. Prerequisite / Prior requirement

      **Meaning:** Aisi cheez jo kisi kaam ko shuru karne se pehle zaroori ho.  
      *Example:* Basic English is a prerequisite for this course.  
      *Meaning:* Is course ke liye basic English aana zaroori hai.

      ---

      ### 5. Optional

      **Meaning:** Jo zaroori nahi hai; apni marzi se kar sakte hain.  
      *Example:* Attendance is optional.  
      *Meaning:* Attendance dena zaroori nahi hai.

      ---

      ### 6. Compare

      **Meaning:** Tulna karna.  
      *Example:* Compare these two phones.  
      *Meaning:* In dono phones ki tulna karo.

      ---

      ### 7. Difference

      **Meaning:** Farq ya antar.  
      *Example:* What's the difference between these two?  
      *Meaning:* In dono mein kya farq hai?

      ---

      ### 8. Similarities

      **Meaning:** Samaantaein.  
      *Example:* What are the similarities between them?  
      *Meaning:* Un dono mein kya samaanta hai?
    MD
  },
  {
    title: "Delay, Focus, Rewards & Penalties",
    date: Date.new(2026, 10, 16),
    markdown: <<~MD
      ### 1. Buy time

      **Meaning:** Kisi kaam se pehle thoda aur samay lena.  
      *Example:* I need to buy some time.  
      *Meaning:* Mujhe thoda aur samay chahiye.

      ---

      ### 2. Late / Delay / Postpone / Procrastinate

      - **Late** — Der se.  
        *Example:* I'm late. — Mujhe der ho gayi hai.

      - **Delay** — Deri hona ya karna.  
        *Example:* Sorry for the delay. — Deri ke liye maaf karna.

      - **Postpone** — Kisi kaam ko baad ke liye taal dena.  
        *Example:* We postponed the meeting. — Humne meeting aage ke liye taal di.

      - **Procrastinate** — Kaam ko baar-baar taalte rehna.  
        *Example:* Don't procrastinate. — Kaam ko taalte mat raho.

      ---

      ### 3. Excuse / Excited

      - **Excuse** — Bahana.  
        *Example:* Stop making excuses. — Bahane banana band karo.

      - **Excited** — Bahut khush ya utsahit.  
        *Example:* I'm excited about the trip. — Main trip ko lekar bahut excited hoon.

      ---

      ### 4. On track / Focused / Distracted

      - **On track** — Sahi direction mein aage badhna.  
        *Example:* I'm back on track. — Main phir se sahi raaste par aa gaya hoon.

      - **Focused** — Dhyan laga kar kaam karna.  
        *Example:* Stay focused on your goal. — Apne goal par dhyan banaye rakho.

      - **Distracted** — Dhyan bhatak jaana.  
        *Example:* I get distracted by my phone. — Mera dhyan phone ki wajah se bhatak jaata hai.

      **Useful sentence:**  
      *I am getting back on track.* — Main phir se apne kaam ya routine par laut raha hoon.

      ---

      ### 5. Fine / Penalty / Reward / Medal / Dopamine

      - **Fine** — Jurmana.  
        *Example:* I had to pay a fine. — Mujhe jurmana bharna pada.

      - **Penalty** — Dand ya jurmana.  
        *Example:* There is a penalty for breaking the rules. — Rules todne par dand hai.

      - **Reward** — Inaam.  
        *Example:* Hard work brings rewards. — Mehnat ka inaam milta hai.

      - **Medal** — Padak.  
        *Example:* She won a gold medal. — Usne gold medal jeeta.

      - **Dopamine** — Dimaag mein paaya jaane wala chemical messenger, jo motivation aur reward se judi processes mein role nibhata hai.

      ---

      ### 6. Fine se related sentences

      - He is asking me to pay a fine. — Woh mujhse jurmana bharne ko keh raha hai.
      - He is demanding that I pay a fine. — Woh mujhse jurmana bharne ki maang kar raha hai.
      - He wants me to pay a fine. — Woh chahta hai ki main jurmana bharun.
      - He is issuing me a fine. — Woh mera jurmana kaat raha hai.

      **Yaad rakho:** “Issue a fine” ka use tab hota hai jab koi authority jurmana lagati hai. “Pay a fine” ka matlab jurmana bharna hai.

      ---

      ### 7. Final Practice

      In Hindi sentences ko English mein bolne ki koshish karo:

      1. Tumne lunch mein kya khaya?
      2. Jaise hi tumhara phone khatam hoga, main market jaungi.
      3. Ye wala kitne ka hai?
      4. Aur batao, kya naya hai?
      5. Main chalta hoon.
      6. Mujhe apni padhai mein aur zyada mehnat karni hai.
      7. Aaj mera bahut busy din tha.
      8. Is topic ko gehrai se samajhna hai.
      9. Is course ke liye basic English aana zaroori hai.
      10. Kaam ko taalna band karo.
      11. Main phir se apne routine par laut raha hoon.
      12. Mujhe jurmana bharna pada.

      **Daily Tip:** Har sentence ko zor se bolo aur apni daily life mein use karne ki koshish karo. English bolna seekhne ke liye regular practice sabse zaroori hai.
    MD
  }
]

puts "\n== Ensuring 6 Daily Classes Exist =="
classes_data.each_with_index do |data, index|
  lesson = Lesson.find_or_initialize_by(title: data[:title])
  lesson.lesson_date = data[:date]
  lesson.status = :published
  lesson.lesson_type = :daily_class
  lesson.author = super_admin
  
  html_content = Kramdown::Document.new(data[:markdown], input: "GFM").to_html
  lesson.content = html_content
  lesson.save!

  puts "Class #{index + 1}: #{lesson.title} (#{lesson.lesson_date.strftime('%d/%m/%Y')})"
end

puts "\n== Seeding Completed Successfully! =="
