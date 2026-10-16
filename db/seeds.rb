# Seed script for Learn English Web App (Idempotent for safe deployment & local seeding)

puts "== Ensuring Super Admin, Admin & Student Users Exist =="
super_admin = User.find_or_create_by!(email_address: "star@learnenglish.com") do |u|
  u.name = "Head Super Admin"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :super_admin
end
super_admin.update!(role: :super_admin) unless super_admin.super_admin?
puts "Super Admin: #{super_admin.email_address} (password: password123)"

teacher = User.find_or_create_by!(email_address: "teacher@learnenglish.com") do |u|
  u.name = "Teacher Admin"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
end
puts "Teacher: #{teacher.email_address} (password: password123)"

student = User.find_or_create_by!(email_address: "rahul@example.com") do |u|
  u.name = "Rahul Sharma"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :student
end
puts "Student: #{student.email_address} (password: password123)"

puts "== Ensuring Admin Shared Word List Exists =="
shared_list = teacher.word_lists.find_or_create_by!(name: "Essential Workplace English") do |l|
  l.is_default = false
end

shared_list.word_entries.find_or_create_by!(term: "Proactive") do |e|
  e.user = teacher
  e.personal_note = "Taking action before a problem occurs rather than reacting after."
end

shared_list.word_entries.find_or_create_by!(term: "In lieu of") do |e|
  e.user = teacher
  e.personal_note = "In place of / instead of (formal substitute)."
end
puts "Shared List: #{shared_list.name}"

puts "== Ensuring Daily Lessons Exist =="
today_lesson = Lesson.find_or_create_by!(title: "Mastering 'Compare' in Everyday English") do |l|
  l.lesson_date = Date.current
  l.status = :published
  l.author = teacher
  l.content = <<~HTML
    <h2>1. Core Meaning in Hinglish</h2>
    <p><strong>Compare</strong> ka simple matlab hota hai: <em>Jab hum do ya zyada cheezon ko saath mein dekhte hain taaki samajh sakein ki unmein kya same hai aur kya different hai.</em></p>
    
    <blockquote>
      <strong>Real-Life Analogy:</strong> Imagine you want to buy a new smartphone. Aap dono ke prices, cameras, battery life aur features ko aamne-saamne rakh kar check karte hain. You are <strong>comparing</strong> them before buying!
    </blockquote>

    <h2>2. Pronunciation Guide</h2>
    <ul>
      <li><strong>IPA:</strong> /kəmˈpeə(r)/</li>
      <li><strong>Easy pronunciation:</strong> kuhm-PAIR</li>
      <li><strong>Stress:</strong> Second syllable par stress dein (-PAIR)</li>
    </ul>

    <h2>3. Natural Everyday Examples</h2>
    <ul>
      <li>Let me <strong>compare</strong> these two options before choosing.</li>
      <li>Don't <strong>compare</strong> your progress with someone else's timeline.</li>
      <li>We need to <strong>compare</strong> the old implementation with the new one.</li>
      <li><strong>Compared with</strong> last month, my English has noticeably improved.</li>
    </ul>

    <h2>4. Word Family</h2>
    <ul>
      <li><strong>Compare</strong> (verb): I like to compare prices.</li>
      <li><strong>Comparison</strong> (noun): There is no comparison between the two.</li>
      <li><strong>Comparable</strong> (adjective): Both offers are of comparable value.</li>
      <li><strong>Comparatively</strong> (adverb): The exam was comparatively easy.</li>
    </ul>

    <h2>5. Common Hindi-Speaker Mistake to Avoid</h2>
    <p>Hindi mein hum bolte hain <em>"Isse compare karo"</em>. English mein:</p>
    <ul>
      <li>Use <strong>Compare A with B</strong> jab do cheezon ko side-by-side analyze karna ho (most common in business & daily talk).</li>
      <li>Use <strong>Compare A to B</strong> jab do alag cheezon ki metaphorical similarity dikhani ho (e.g. <em>"He compared her voice to music"</em>).</li>
    </ul>

    <h2>6. Quick Recap</h2>
    <ul>
      <li>Compare = Do cheezon mein similarities aur differences dekhna.</li>
      <li>Pronounce it as <strong>kuhm-PAIR</strong>.</li>
      <li>Collocation: <strong>Compared with last year...</strong></li>
    </ul>
  HTML
end

earlier_lesson = Lesson.find_or_create_by!(title: "Understanding the Phrase 'Take for Granted'") do |l|
  l.lesson_date = Date.current - 1.day
  l.status = :published
  l.author = teacher
  l.content = <<~HTML
    <h2>What does 'Take for Granted' mean?</h2>
    <p>Aksar hum kisi insaan, rishte ya suvidha ki value tab tak nahi samajhte jab tak woh chali na jaaye. Hum pehle se maan lete hain ki <em>"Yeh toh hamesha mere paas rahega hi"</em>.</p>
    <p>Is attitude ya feeling ko English mein kehte hain: <strong>To take something for granted</strong>.</p>

    <blockquote>
      <strong>Example Story:</strong> Jab tak light rehti hai hum dhyaan nahi dete, lekin jaise hi power cut hota hai tab ehsaas hota hai hum bijli ko kitna <strong>take for granted</strong> lete the!
    </blockquote>

    <h2>Everyday Sentences</h2>
    <ul>
      <li>Never <strong>take</strong> your good health <strong>for granted</strong>.</li>
      <li>He felt his boss <strong>took</strong> his hard work <strong>for granted</strong>.</li>
      <li>Don't <strong>take</strong> your friends <strong>for granted</strong>.</li>
    </ul>

    <h2>Common Mistake</h2>
    <p>Kabhi sirf <em>"take granted"</em> mat bolein. It is always: <strong>take [something / someone] for granted</strong>.</p>
  HTML
end

my_words_list = student.word_lists.find_by(name: "My Words")
to_learn_list = student.word_lists.find_by(name: "To Learn")
revision_list = student.word_lists.find_by(name: "Revision")

if my_words_list
  my_words_list.word_entries.find_or_create_by!(term: "Compare") do |e|
    e.user = student
    e.lesson = today_lesson
    e.personal_note = "Do cheezon mein farq dekhna (kuhm-PAIR)"
    e.status = :learning
    e.needs_revision = true
  end

  my_words_list.word_entries.find_or_create_by!(term: "Nuance") do |e|
    e.user = student
    e.personal_note = "Chhota sa barik farq jo aasani se na dikhe"
    e.status = :new_word
    e.needs_revision = false
  end
end

if to_learn_list
  to_learn_list.word_entries.find_or_create_by!(term: "Overwhelmed") do |e|
    e.user = student
    e.personal_note = "Jab kaam ya emotions itne zyada ho jaayein ki handle na ho sakein"
    e.status = :new_word
    e.needs_revision = true
  end
end

if revision_list
  revision_list.word_entries.find_or_create_by!(term: "Take for granted") do |e|
    e.user = student
    e.lesson = earlier_lesson
    e.personal_note = "Kisi cheez ki kadar na karna kyunki assume kiya hai woh hamesha rahegi"
    e.status = :learning
    e.needs_revision = true
  end
end

puts "== Seeding Completed Successfully! =="
