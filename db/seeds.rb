# Seed script for Learn English Web App

puts "== Cleaning old seed records =="
LessonCompletion.destroy_all
WordEntry.destroy_all
WordList.destroy_all
Lesson.destroy_all
Session.destroy_all
User.destroy_all

puts "== Creating Users =="
teacher = User.create!(
  name: "Teacher Admin",
  email_address: "teacher@learnenglish.com",
  password: "password123",
  password_confirmation: "password123",
  role: :admin
)
puts "Created Teacher: #{teacher.email_address} (password: password123)"

student = User.create!(
  name: "Rahul Sharma",
  email_address: "rahul@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: :student
)
puts "Created Student: #{student.email_address} (password: password123)"

puts "== Creating Admin Shared Word List =="
shared_list = teacher.word_lists.create!(
  name: "Essential Workplace English",
  is_default: false
)
shared_list.word_entries.create!(
  user: teacher,
  term: "Proactive",
  personal_note: "Taking action before a problem occurs rather than reacting after."
)
shared_list.word_entries.create!(
  user: teacher,
  term: "In lieu of",
  personal_note: "In place of / instead of (formal substitute)."
)
puts "Created Shared List: #{shared_list.name} with 2 words"

my_words_list = student.word_lists.find_by(name: "My Words")
to_learn_list = student.word_lists.find_by(name: "To Learn")
revision_list = student.word_lists.find_by(name: "Revision")

puts "== Creating Reference Daily Lesson: 'Mastering Compare' =="
today_lesson = Lesson.create!(
  title: "Mastering 'Compare' in Everyday English",
  lesson_date: Date.current,
  status: :published,
  author: teacher,
  content: <<~HTML
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
)

puts "== Creating Earlier Lesson: 'Take for Granted' =="
earlier_lesson = Lesson.create!(
  title: "Understanding the Phrase 'Take for Granted'",
  lesson_date: Date.current - 1.day,
  status: :published,
  author: teacher,
  content: <<~HTML
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
)

puts "== Adding Sample Words to Student's Lists =="
my_words_list.word_entries.create!(
  user: student,
  lesson: today_lesson,
  term: "Compare",
  personal_note: "Do cheezon mein farq dekhna (kuhm-PAIR)",
  status: :learning,
  needs_revision: true
)

my_words_list.word_entries.create!(
  user: student,
  term: "Nuance",
  personal_note: "Chhota sa barik farq jo aasani se na dikhe",
  status: :new_word,
  needs_revision: false
)

to_learn_list.word_entries.create!(
  user: student,
  term: "Overwhelmed",
  personal_note: "Jab kaam ya emotions itne zyada ho jaayein ki handle na ho sakein",
  status: :new_word,
  needs_revision: true
)

revision_list.word_entries.create!(
  user: student,
  lesson: earlier_lesson,
  term: "Take for granted",
  personal_note: "Kisi cheez ki kadar na karna kyunki assume kiya hai woh hamesha rahegi",
  status: :learning,
  needs_revision: true
)

puts "== Seeding Completed Successfully! =="
