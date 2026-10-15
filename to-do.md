# Build a Minimalist English Vocabulary Learning Web App

## 1. Project Goal

Build a simple, minimalist, mobile-friendly web application for teaching English vocabulary, phrases, sentences, expressions, and concepts to Hindi/Hinglish-speaking students.

The purpose is to help students understand English deeply, not just memorize dictionary meanings.

Classes will be conducted primarily in **Hinglish (natural Hindi + English in Roman script)**, with simple English examples. Avoid overly formal Hindi or difficult linguistic terminology unless you explain it simply.

I will personally create and publish a new lesson page every day. Students will log in, study daily lessons, revise previous classes, and maintain their own personal vocabulary lists.

Before implementing anything, inspect the existing repository, understand its structure and technology stack, and follow its conventions. If this is a new project, choose a simple, maintainable stack and explain the choice before proceeding if there is a significant trade-off.

Do not overengineer the application.

## 2. Design Philosophy

The application should feel calm, clean, modern, and distraction-free.

Design references: minimalist educational tools, Notion, Linear, and simple reading-focused websites.

Requirements:
- White or subtle off-white background.
- Neutral colors with one restrained accent color.
- Clear typography and comfortable reading width.
- Generous whitespace.
- Simple cards, subtle borders, and restrained shadows.
- Minimal icons.
- Consistent spacing and typography.
- Responsive layouts for desktop, tablet, and mobile.
- Accessible contrast, keyboard navigation, and visible focus states.
- Light and dark mode are optional; prioritize the core experience first.

Avoid:
- Excessive gradients and bright colors.
- Unnecessary animations.
- Large decorative illustrations.
- Excessive dashboards, charts, badges, or statistics.
- Social feeds, leaderboards, gamification, or other features unrelated to learning.
- A complicated admin panel.

The content and readability must be the main focus.

## 3. User Authentication and Roles

Implement secure authentication with:
- Sign up.
- Login.
- Logout.
- Forgot password and password reset.
- Appropriate validation and error messages.
- Protected pages for authenticated users.

Support two roles:

**Admin / Teacher (me)**
- Create, edit, preview, publish, unpublish, and archive lessons.
- Organize lessons by date, topic, and category.
- Reorder lesson sections.
- Preview the student experience before publishing.
- View lesson content in a readable editor.
- Revise or correct published lessons without losing data unnecessarily.

**Student**
- Browse published lessons.
- Open daily classes.
- Revisit previous classes.
- Save words to personal lists.
- Add custom words at any time.
- Mark words and lessons for revision.
- Track basic learning progress.

Students must never be able to modify official lesson content or access another student's private word lists.

## 4. Main Pages

### A. Home / Student Dashboard

Keep it simple.

Display:
- Today's lesson, if published.
- Most recent lessons.
- A button to continue learning.
- A quick-add field for a word the student wants to learn later.
- Personal word lists.
- Words due for revision.
- Previously completed lessons.

If no lesson has been published for today, show the latest available lesson and a friendly message. Do not show an empty or broken dashboard.

### B. Daily Lessons

I will add a lesson page every day.

A lesson can contain any combination of:
- Revision of previous classes.
- New vocabulary words.
- Phrases and expressions.
- Common English sentences.
- Grammar or language concepts.
- Real-life situations and dialogues.
- Exercises, quizzes, or practice activities.

Do not force every lesson into a fixed structure. Each lesson should support flexible sections that I can add, remove, reorder, and edit.

Every lesson should include:
- Title.
- Date.
- Optional topic or category.
- Short introduction.
- Flexible content sections.
- Optional recap and practice questions.
- Previous and next lesson navigation when available.
- A way to save individual words to a personal list.
- A way to mark the lesson as completed or needing revision.

The student interface should be a comfortable reading experience, not a complex course-management system.

### C. Personal Word Lists

This is a core feature.

Students often remember a word they want to learn, but the next class may be several hours away. They must be able to save the word immediately without waiting for the teacher to cover it.

Implement:
- Quick-add word input, available from the dashboard and a dedicated word-list page.
- Add a word, phrase, or sentence.
- Optional personal note or example.
- Edit and delete personal entries.
- Organize entries into custom lists.
- Default lists such as "My Words", "To Learn", and "Revision".
- Search and filter.
- Mark an entry as learned or needing revision.
- Add a word from an official lesson to a personal list.
- Prevent accidental duplicate entries within the same list, or warn the user.
- Preserve personal entries across sessions.

The student should be able to add a word in seconds, even if they do not know its meaning yet.

For example, a student types "compare", saves it, and learns it later during a lesson or revision session.

Keep personal word lists private to their owner.

### D. Lesson Authoring (Admin)

Create a straightforward admin interface for preparing lessons.

I should be able to:
- Create a lesson with a title and date.
- Add multiple content blocks.
- Choose the block type.
- Edit and reorder blocks.
- Save drafts.
- Preview the lesson.
- Publish when ready.
- Edit or unpublish an existing lesson.

Suggested block types:
1. Rich text / explanation.
2. Vocabulary word.
3. Phrase or expression.
4. Example sentences.
5. Dialogue or real-life scenario.
6. Revision activity.
7. Quiz or question.
8. Summary / recap.

For vocabulary blocks, use the detailed word structure described below.

I will create the content manually. Do not make AI-generated lesson content mandatory. AI-assisted content generation can be a future enhancement.

## 5. Comprehensive Vocabulary Learning Structure

A word must be taught deeply, not just through a definition and two examples.

For example, a lesson about the word "compare" should help students understand its meaning, pronunciation, usage, tone, intensity, context, and natural application in daily life.

Each vocabulary entry should support the following sections. All sections must be optional, so I can choose what to teach on a given day.

### A. Core Meaning
- Word or expression.
- Simple English definition.
- Meaning explained in natural Hinglish.
- Easy explanation in everyday language.
- Different meanings and uses.
- Literal versus figurative meaning, where relevant.
- A memorable real-life analogy or short story.
- Situations in which the word is useful.

### B. Pronunciation and Sound
- IPA pronunciation.
- Easy pronunciation guide.
- Syllable breakdown.
- Stressed syllable.
- Common pronunciation mistakes.
- Connected speech or natural spoken pronunciation, where relevant.
- Optional audio pronunciation, if available.

Do not invent IPA or audio. Only show pronunciation information that is reliable.

### C. Tone and Emotional Character
Explain how the word feels in different contexts:
- Neutral tone.
- Positive tone.
- Negative tone.
- Friendly, formal, critical, sarcastic, reassuring, or other relevant tones.
- Emotional weight: how serious or emotionally loaded it feels.
- Intensity: mild, moderate, or strong.
- Connotation: what the word may suggest beyond its literal meaning.
- How tone changes according to context, surrounding words, or delivery.

Use examples to demonstrate differences. Do not incorrectly label a word as inherently positive or negative when its tone depends on context.

### D. Grammar and Usage
- Part of speech.
- Noun, verb, adjective, adverb, and other related forms, where they exist.
- Verb forms, when applicable.
- Grammar patterns.
- Common prepositions.
- Collocations: words commonly used together.
- Sentence structures.
- Natural everyday examples.
- Professional or workplace examples.
- Common mistakes made by Hindi-speaking learners.

Clearly distinguish a word's actual grammatical forms from related words.

### E. Synonyms and Antonyms
- Common synonyms.
- Simple Hinglish explanations of their differences.
- Differences in strength, tone, formality, and context.
- Antonyms and their usage.
- Related words and word families.
- Examples showing when one synonym is more appropriate than another.

Avoid presenting synonyms as perfectly interchangeable when they are not.

### F. Expressions and Phrases
- Idioms.
- Common expressions.
- Phrasal verbs, where relevant.
- Everyday phrases built around the word.
- Common sentence patterns.
- Natural spoken English.
- Formal alternatives, where useful.

Explain each expression in Hinglish and provide practical examples.

### G. Social and Professional Context
- Formal versus informal usage.
- Professional versus casual usage.
- Politeness.
- Whether a phrase might sound rude, judgmental, demanding, or overly formal.
- Possible implications or misunderstandings.
- How to use the word with friends, colleagues, managers, and strangers.

### H. Practical Mastery
- Real-life scenarios.
- Short stories and dialogues.
- Context-specific examples.
- Common learner mistakes.
- Incorrect versus correct sentences.
- Frequency or commonness, when reliable.
- Practice questions.
- Fill-in-the-blank exercises.
- Sentence formation.
- Recall questions.
- A short recap.

Use a sensible layout with collapsible sections or a clear hierarchy so that comprehensive content does not overwhelm students. Keep the most important explanation visible first.

## 6. Example Vocabulary Lesson: "Compare"

Use this as a reference for the content model and presentation.

**Word:** Compare

**Simple meaning:** To look at two or more things to understand how they are similar or different.

**Hinglish explanation:** Jab hum do ya zyada cheezon ko saath mein dekhte hain, taaki samajh sakein ki unmein kya same hai aur kya different hai, toh hum unhe compare karte hain.

**Real-life story:** Imagine you want to buy two laptops. You check their prices, battery life, performance, and weight. You are comparing the laptops before making a decision.

**Everyday examples:**
- Let me compare these two phones.
- Don't compare your progress with someone else's.
- We need to compare the old implementation with the new one.
- Compared with last month, my English has improved.

**Word family:**
- Compare — verb.
- Comparison — noun.
- Comparable — adjective.
- Comparative — adjective or noun, depending on context.
- Comparatively — adverb.

Explain each form accurately with examples.

**Pronunciation:**
- Include a verified IPA transcription.
- Give a simple learner-friendly pronunciation guide.
- Explain syllables and stress.

**Tone and context:**
- Neutral: "Let's compare the two reports."
- Collaborative: "We can compare our results and learn from each other."
- Frustrated: "Stop comparing me with him!"
- Explain that the word itself is not necessarily negative; the sentence and situation determine the tone.

**Synonyms:** Contrast, evaluate, assess, examine.

Explain how each differs from "compare", with examples.

**Grammar and common patterns:**
- Compare A with B.
- Compare A to B.
- Compare prices.
- Compare the results.
- Compared with last year, sales have increased.

Explain natural usage and common learner errors.

**Practice:**
- Ask the student to compare two everyday objects.
- Ask them to write three sentences using "compare".
- Include a short quiz with answers or feedback.

The content above is illustrative. The application must let me write my own definitions, stories, examples, and explanations for every lesson.

## 7. Revision System

Learning should include revision, not just reading new material.

Implement a lightweight revision system:
- Mark words as "New", "Learning", or "Learned".
- Allow students to mark difficult words for revision.
- Provide a revision page containing saved and previously studied words.
- Allow manual revision scheduling initially.
- Optionally introduce simple spaced repetition later, after the core functionality is stable.
- Include quick recall questions and short quizzes when a lesson contains them.

On a new daily lesson, I should be able to add a revision section that references words or concepts from earlier lessons.

Do not automatically generate revision content unless explicitly implemented as a separate, optional feature.

## 8. Search and Navigation

Provide:
- Search across published lesson titles and content.
- Search personal word lists.
- Search by word or phrase.
- Browse lessons by date.
- Optional filtering by topic or category.
- A simple sidebar on desktop and a compact mobile navigation.

Keep navigation limited to the important destinations:
- Home.
- Daily Classes.
- My Words.
- Revision.
- Profile.
- Admin / Manage Lessons, for the teacher only.

## 9. Suggested Data Model

Adapt this to the project's existing architecture rather than following it blindly.

**Users**
- id
- name
- email
- password digest or secure authentication reference
- role
- timestamps

**Lessons**
- id
- title
- slug
- lesson date
- introduction
- status (draft, published, archived)
- author id
- timestamps

**Lesson Blocks**
- id
- lesson id
- block type
- content (structured JSON or appropriate normalized fields)
- position
- timestamps

**Personal Word Lists**
- id
- user id
- name
- timestamps

**Personal Word Entries**
- id
- user id
- word list id
- word or phrase
- personal note
- status
- source lesson/block reference, optional
- revision metadata, optional
- timestamps

Choose a practical data structure for rich vocabulary content. Make sure the teacher can edit different sections independently and reorder lesson blocks without losing their data.

Add appropriate indexes, uniqueness constraints, validations, and authorization rules.

## 10. Technical Requirements

- First inspect the existing project and its current framework, dependencies, conventions, and database.
- Reuse the existing stack whenever reasonable.
- If starting from scratch, select a well-supported, maintainable stack appropriate for a small educational application.
- Implement real authentication and persistent database storage; do not create a frontend-only mockup.
- Protect admin routes and enforce authorization on the server.
- Validate and sanitize user input.
- Avoid exposing private data across accounts.
- Add database migrations and seed data where appropriate.
- Use reusable UI components.
- Keep business logic understandable and testable.
- Add tests for authentication, permissions, lesson publishing, personal word lists, and important validation rules.
- Provide clear setup instructions and environment-variable documentation.
- Do not commit secrets or hardcode credentials.
- Do not commit or push changes unless I explicitly request it.

If the existing project already has authentication, roles, UI components, or database conventions, extend those rather than rebuilding them unnecessarily.

## 11. Implementation Plan

Work in small, verifiable phases.

**Phase 1 — Inspect and Plan**
- Inspect the repository.
- Identify the stack, existing functionality, and missing pieces.
- Propose the data model and page structure.
- Identify any important questions or trade-offs before making significant architectural decisions.

**Phase 2 — Core Application**
- Authentication.
- Student and admin roles.
- Responsive application layout.
- Database setup and migrations.

**Phase 3 — Lessons**
- Lesson authoring.
- Flexible content blocks.
- Draft and publish workflow.
- Student lesson pages.
- Date-based lesson navigation.

**Phase 4 — Personal Vocabulary**
- Quick-add words.
- Personal lists.
- Edit and delete.
- Search.
- Save words from lessons.
- Privacy and ownership checks.

**Phase 5 — Learning and Revision**
- Learning statuses.
- Lesson completion.
- Revision page.
- Optional quizzes and practice activities.

**Phase 6 — Testing and Polish**
- Run relevant tests.
- Fix bugs.
- Check responsive layouts.
- Check empty states, validation, and error handling.
- Verify that students cannot modify lessons or access other users' lists.
- Document setup, features, and remaining limitations.

Do not implement all phases in one uncontrolled change. Complete and verify each phase before moving to the next.

## 12. Definition of Done

The application is ready for its initial release when:

1. Students can sign up, log in, and log out.
2. I can create and publish a daily lesson.
3. Students can read published lessons on desktop and mobile.
4. A lesson can contain flexible combinations of vocabulary, explanations, examples, phrases, and revision content.
5. Students can save their own words at any time, even if the teacher has not taught those words yet.
6. Personal words persist in the database and remain private to each student.
7. Students can search their lists and mark words for revision.
8. I can update lesson content without manually editing database records.
9. Authentication, authorization, validation, and core workflows have tests.
10. The UI remains minimalist, readable, and easy to use.

## Final Instruction

Prioritize a functional, polished minimum viable product over an elaborate platform.

Start by inspecting the repository and reporting:
1. Existing technology stack.
2. Existing functionality that can be reused.
3. Proposed implementation plan.
4. Important decisions or blockers.

Then proceed with implementation in phases. Ask me only when a decision genuinely requires my input. Do not invent existing functionality, claim tests passed without running them, or make unrelated changes.
