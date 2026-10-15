# Learn English — Minimalist Hinglish Vocabulary Web App

A clean, mobile-friendly web application for teaching English vocabulary, phrases, expressions, and concepts deeply to Hindi/Hinglish-speaking learners.

Built with **Ruby on Rails 8**, **Hotwire (Turbo + Stimulus)**, and **Tailwind CSS**.

---

## 1. Key Features

- **Concept-First Hinglish Learning**: Daily lessons structured around deep understanding (IPA pronunciation, syllable stress, natural everyday Hinglish explanations, real-life stories, tone nuances, word families, and common Hindi-speaker mistakes).
- **Personal Vocabulary Notebook**:
  - Quick-add any word in seconds from the dashboard, lessons, or word lists.
  - Automatic default lists: *My Words*, *To Learn*, and *Revision*, plus custom lists.
  - 1-Click "Save to My Words" directly from daily lesson vocabulary cards.
  - Strict privacy scoping: Students can only view, edit, and search their own words.
- **Lightweight Revision System**:
  - Learning status pipeline: `New Word` → `Learning` → `Learned`.
  - Flag difficult words for revision (`needs_revision`).
  - Active recall queue with "Mark Reviewed" and "Mastered" one-click triggers.
- **Teacher Studio (Admin)**:
  - Simple, fast lesson authoring: Title, Date, Status (Draft / Published), and Rich Text Content.
  - Full Action Text editor: Write natural Hinglish, format with bullet points, numbered lists, headings, quotes, and upload images directly.
  - Live preview of the student reading experience before publishing.
  - Protected by strict server-side authorization filters (`require_admin`).
- **Minimalist Aesthetic**:
  - Distraction-free Notion / Linear-inspired UI.
  - Neutral stone palette with restrained accents, comfortable reading width, and fully responsive layouts.

---

## 2. Technology Stack

- **Backend**: Ruby 3.4+, Ruby on Rails 8.1.3
- **Frontend**: Hotwire (Turbo Drive, Turbo Frames, Stimulus) + Tailwind CSS v4
- **Authentication**: Native Rails 8 authentication (BCrypt, Session cookies, password resets)
- **Database**:
  - **Development & Testing**: SQLite 3 with WAL mode (fast, concurrent, zero-daemon setup).
  - **Production Hosting**: MySQL or PostgreSQL via `DATABASE_URL` (configured in `config/database.yml`).

---

## 3. Quick Start

### Prerequisites
- Ruby 3.4+ (e.g. via `rbenv`)
- Bundler (`gem install bundler`)
- SQLite 3

### Setup & Run
```bash
# 1. Install dependencies
bundle install

# 2. Run migrations and seed data
bin/rails db:prepare
bin/rails db:seed

# 3. Start development server
bin/dev
# or
bin/rails server
```

The app will be accessible at: `http://localhost:3000`

---

## 4. Default Seed Accounts

After running `bin/rails db:seed`, the following accounts are ready:

| Role | Email | Password | Access |
|---|---|---|---|
| **Teacher / Admin** | `teacher@learnenglish.com` | `password123` | Full access to Teacher Studio (`/admin/lessons`), authoring, editing, publishing, reordering blocks |
| **Student** | `rahul@example.com` | `password123` | Student dashboard, daily classes, personal word lists, revision queue |

You can also sign up for a brand new student account at `/registration/new`.

---

## 5. Running Automated Tests

Run the complete test suite:
```bash
bin/rails test
```

The automated test suite covers:
- User registration, validations, and automatic default word list creation
- Native Rails 8 authentication and session lifecycle
- Teacher Studio authorization barriers (students blocked with 302/alerts)
- Daily lesson publishing, draft protection, completion toggling, and date navigation
- Personal word lists and strict multi-tenant privacy (verifying Student A cannot see or edit Student B's lists or entries)
- Revision status transitions and queue filters

---

## 6. Production Database: MySQL or PostgreSQL

To deploy with MySQL or PostgreSQL, configure the `DATABASE_URL` environment variable on your server/host:

- **MySQL**:
  ```bash
  DATABASE_URL=mysql2://user:password@hostname:3306/dbname
  ```
- **PostgreSQL**:
  ```bash
  DATABASE_URL=postgresql://user:password@hostname:5432/dbname
  ```
