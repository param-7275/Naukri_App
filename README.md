# Job Portal

An end-to-end hiring platform built with Rails 7.1 where recruiters publish roles, job seekers apply with rich profiles, and premium upgrades surface the best talent. The application ships with automated email notifications, Sidekiq-powered lifecycle jobs, Stripe billing, and an AI job-description generator.

---

## Product Overview

- **Two personas:** recruiters manage postings and review applicants; job seekers discover roles, apply with resumes, and track their status.
- **Premium access:** Stripe-powered subscriptions unlock fresh job listings while free users see roles older than seven days.
- **Smart assistance:** recruiters can generate full job descriptions from a title via OpenAI (`gpt-4o-mini`) through the `/generate_ai_description` endpoint and Stimulus UI.
- **Retention tooling:** rejected candidates automatically regain the ability to re-apply after three months, with reminder emails handled by scheduled Sidekiq jobs.
- **Global-ready UI:** navigation and forms are localized (`en`, `hi`, `es`, `pa`) with locale-aware routes `/:locale/...`.
- **Operational visibility:** Sidekiq Web UI is mounted at `/sidekiq`, and Stripe webhooks keep subscription state in sync.

---

## Application Flow At A Glance

1. **Onboarding**
   - Users sign up via `UsersController#new_signup`, choosing `job_seeker` or `recruiter`. Phone, email, and password strength validations are enforced by `User` model (Devise).
   - Session-based login (`UsersController#user_login`) redirects to persona dashboards (`/recruiter_index` or `/jobseeker_index`).

2. **Recruiter journey**
   - Create roles from `/new` → `JobsController#create`. Successful posts trigger `NotificationMailer.job_posted` to all job seekers.
   - Review owned postings at `/index` and manage applicants from `/recruiter_applicants`, updating statuses (review/reject/interview/hired).
   - Deep-link to any job description page (`/view_job_description/:job_id`). AI descriptions can be generated mid-form using the Stimulus controller in `app/javascript/controllers/ai_generator_controller.js`.

3. **Job seeker journey**
   - Explore listings at `/all_jobs`. Free users see week-old jobs; premium users (active subscription + `is_premium`) see every posting immediately.
   - Apply via `/job_applications/new/:job_id`. `JobApplication` enforces a PDF resume and a 200–1000 character narrative.
   - Track submissions at `/applied_jobs`. Rejected applications show when reapply is allowed and deep-link to `/job_applications/:id/reapply/edit`.

4. **Subscriptions & billing**
   - Pricing page (`/plan_and_pricing`) compares Free vs Premium.
   - Checkout starts at `/subscriptions/new`, which creates or reuses a Stripe Customer, prepares a PaymentIntent, and exposes `@client_secret` to the form.
   - On success (`/subscriptions/success`), the user is upgraded, a Stripe subscription is created from the local `Plan`, and a `Subscription` record mirrors the Stripe metadata.
   - Stripe webhooks (`POST /webhooks/stripe`) keep `Subscription#status` and `ended_at` aligned with Stripe lifecycle events.

5. **Lifecycle automation**
   - `ReapplyUnlockJob` (cron-driven via `config/schedule.yml`) flips `reapply_allowed` back to true 90 days after rejection and emails the candidate through `JobReapplyNotificationMailer`.
   - `PremiumEndJob` downgrades expired subscribers, updates `Subscription#status`, and sends `SubscriptionEndedMailer`.

---

## Tech Stack

- **Backend:** Ruby 3.4.4, Rails 7.1, Devise authentication, Sidekiq + Redis for background jobs.
- **Frontend:** ERB views enhanced with Turbo, Stimulus via Importmap (`app/javascript`), and Tailored CSS per view.
- **Storage:** SQLite (development/test), Active Storage (local disk) for resumes, Action Text tables are present for future rich content.
- **Integrations:** Stripe (PaymentIntent + Subscriptions API, Webhooks), OpenAI (`ruby-openai`), SMTP (config includes Gmail defaults), Redis (Sidekiq + caching).
- **Tooling:** dotenv-rails, letter_opener (dev), Sidekiq cron scheduler, Dockerfile for production builds.

Key directories:

- `app/models`: `User`, `Job`, `JobApplication`, `Subscription`, `Plan`.
- `app/controllers`: Persona flows (`JobsController`, `JobApplicationsController`, `UsersController`), billing (`SubscriptionsController`), webhooks.
- `app/jobs`: `ReapplyUnlockJob`, `PremiumEndJob`.
- `app/mailers`: Notification, subscription, and reapply emails.
- `app/javascript/controllers`: Stimulus controllers (`ai_generator_controller.js`).
- `config/initializers`: Stripe, Redis, Sidekiq scheduler, Devise, locales.

---

## Feature Breakdown

**Recruiter capabilities**
- Post, edit, and delete jobs with granular fields (company details, skills, education, salary, work mode).
- AI-assisted job description writing (fetches `/generate_ai_description?title=...`).
- Applicant tracking dashboard with status transitions and resume downloads (`ActiveStorage`).

**Job seeker capabilities**
- Role discovery carousel, premium gating, and quick links to detailed descriptions.
- Application form with validations, resume upload, and real-time duplicate prevention (`JobApplication` uniqueness scope).
- Application history with status chips, reapply flow, and premium upsell.

**Platform services**
- Stripe-powered premium subscriptions with automated renewal tracking.
- Scheduled jobs that unlock reapplications and expire subscriptions.
- Mailing pipeline for job postings, reapply reminders, and subscription expiry.
- Locale-aware navigation and error handling.

---

## Data Model (Simplified)

- `users`: Devise-backed authentication plus role (`job_seeker` / `recruiter`), premium flags, and Stripe identifiers.
- `jobs`: Belongs to a recruiter; holds all descriptive metadata shown to seekers.
- `job_applications`: Join between job and job seeker, storing resume (ActiveStorage), narrative, status, and `reapply_allowed`.
- `plans`: Configurable subscription plan (seeded with “Premium” ₹499).
- `subscriptions`: Mirrors the Stripe subscription lifecycle (status, window, price) per user.

Refer to `db/schema.rb` for the authoritative structure.

---

## Prerequisites

- Ruby 3.4.4 (see `.ruby-version`)
- Bundler 2.x
- SQLite 3.36+
- Redis 6+ (for Sidekiq + cached services)
- Node/Yarn not required (Importmap is used)
- Optional: Docker + Compose for containerized deploys

---

## Local Setup

```bash
# 1. Install gems
bundle install

# 2. Prepare database (creates, migrates, seeds plan)
bin/rails db:setup    # equivalent to db:create db:migrate db:seed

# 3. Ensure Redis is running
redis-server /usr/local/etc/redis.conf

# 4. Start Sidekiq for background jobs & cron tasks
bundle exec sidekiq

# 5. Boot the Rails server
bin/rails server
```

- Default app URL: `http://localhost:3000`
- Seed data inserts the base premium plan via `db/seeds.rb`. Add sample users/jobs via `rails console` or fixtures.

---

## Configuration & Secrets

Most secrets live in Rails credentials (`config/credentials.yml.enc`). Set `RAILS_MASTER_KEY` in your shell or deployment platform so Rails can decrypt them.

| Secret | Purpose |
| --- | --- |
| `STRIPE_PUBLIC_KEY`, `STRIPE_SECRET_KEY` | Required for Stripe JS + server APIs (`config/initializers/stripe.rb`). |
| `STRIPE_WEBHOOK_SECRET` | Validates `/webhooks/stripe` payloads. |
| `OPENAI_API_KEY` | Enables `/generate_ai_description` responses. |
| `REDIS_URL` | Overrides default `redis://localhost:6379/0` if needed. |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | Replace the Gmail defaults found in `config/environments/development.rb`. |
| `HOST_URL`, `MAILER_HOST` (optional) | Used in mailers for absolute URLs. |

Use `bin/rails credentials:edit` to add them, or export environment variables in development (dotenv is available).

---

## Running The Platform

- **Rails server:** `bin/rails server`
- **Background jobs:** `bundle exec sidekiq`
- **Scheduler:** Managed by `sidekiq-scheduler` loading `config/schedule.yml` (both jobs currently run every minute—adjust cron expressions before production).
- **Sidekiq dashboard:** Visit `http://localhost:3000/sidekiq` (authentication recommended before production).
- **Stripe webhook tunneling:** Use `stripe listen --forward-to localhost:3000/webhooks/stripe`.
- **AI generation:** Requires reachable OpenAI API. The Stimulus controller disables the button and shows alerts on failure.

---

## Subscriptions & Payments

1. User clicks “Upgrade to Premium” on `/plan_and_pricing`.
2. `SubscriptionsController#new` ensures a Stripe Customer exists and creates a PaymentIntent (`@client_secret` passes to the JS form).
3. After client-side confirmation, Stripe redirects to `/subscriptions/success?payment_intent=...`.
4. `#success` verifies the PaymentIntent, promotes the user, builds a Stripe Subscription based on the local `Plan`, and persists a `Subscription`.
5. Sidekiq cron job monitors `Subscription#ended_at`. When overdue, `PremiumEndJob` downgrades the user and sends `SubscriptionEndedMailer`.
6. Webhooks (`customer.subscription.*`) keep local status aligned with pauses/cancellations triggered directly in Stripe.

---

## AI Job Description Generator

- Route: `GET /generate_ai_description?title=<job title>`
- Auth: Recruiter-only (`JobsController#ensure_recruiter!`).
- Logic:
  - Validates presence of `title`.
  - Uses `OpenAI::Client` (`ruby-openai`) with `gpt-4o-mini`, low temperature, and a structured prompt dictating sections (Job Title, Location, Responsibilities, etc.).
  - Returns `{ description: "..." }` JSON consumed by Stimulus to auto-fill the job description textarea.
- Failure paths return JSON error messages, surfaced to users via alerts.

---

## Background Jobs & Notifications

- `ReapplyUnlockJob` (cron): Finds rejected applications older than 3 months, toggles `reapply_allowed`, and emails candidates (`JobReapplyNotificationMailer#reapply_available`).
- `PremiumEndJob` (cron): Finds expired subscriptions, sets status to “Inactive”, flips `user.is_premium` false, and sends `SubscriptionEndedMailer`.
- `NotificationMailer#job_posted`: Enqueued after every new job, notifying all job seekers.
- All jobs run through Sidekiq using the Redis host configured in `config/initializers/sidekiq.rb`.

---

## Testing & Quality

- **Unit & integration tests:** `bin/rails test`
- **System tests (Capybara/Selenium):** `bin/rails test:system`
- **Mail previews:** available in `test/mailers/previews` (start Rails server and visit `/rails/mailers`).
- **Background job tests:** see `test/jobs/`.

Before running tests, ensure the test database is migrated: `bin/rails db:test:prepare`.

---

## Deployment Notes

- **Docker:** Use the provided multi-stage `Dockerfile`. Build with `docker build -t job-portal .` and run the container with the required environment variables (Stripe, OpenAI, Redis URL, RAILS_MASTER_KEY). The image expects assets precompiled and runs `bin/docker-entrypoint`.
- **Process formation:** At minimum you need `web` (Rails) and `worker` (Sidekiq) processes plus Redis.
- **Mail:** Update SMTP credentials and hostnames for production. Consider moving secrets out of source-controlled files.
- **Security hardening:** Protect `/sidekiq`, validate Stripe webhooks in non-development environments, and move Gmail password out of `development.rb`.

---

## Troubleshooting

- **OpenAI errors:** Verify `OPENAI_API_KEY`, and check server logs for `OpenAI API Error`.
- **Stripe webhook signature errors:** Ensure the webhook secret in credentials matches the CLI listener or dashboard endpoint.
- **Sidekiq jobs not running:** Confirm Redis is reachable (see `config/initializers/redis.rb`) and check the Sidekiq dashboard for scheduler state.
- **File uploads failing:** Active Storage defaults to local disk; ensure `storage/` is writable and PDF resumes are enforced via validations.
- **Localized routes 404:** Routes are scoped under `/:locale`. Include the locale prefix (`/en/login`) or rely on default `en`.

---

## Useful Commands

```bash
# Database
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Consoles
bin/rails console
bin/rails routes | grep jobs

# Lint / diagnostics
bundle exec ruby -c path/to/file.rb

# Background job dashboard
open http://localhost:3000/sidekiq
```

---

## Next Steps

- Lock down Sidekiq and Stripe webhooks with authentication in production.
- Replace plaintext SMTP credentials with environment variables.
- Expand test coverage for subscription flows and AI generation.
- Configure CDN/Active Storage cloud service for production resumes.

This README should give any contributor or operator enough context to run, extend, and reason about the Job Portal’s flow end-to-end. Happy shipping!
