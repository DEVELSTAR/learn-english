#!/usr/bin/env bash
# exit on error
set -o errexit

mkdir -p storage tmp/pids

# Run pending database migrations on primary database (Supabase)
bundle exec rails db:migrate

# Ensure tables exist for Solid Cache, Solid Queue, and Solid Cable SQLite databases
bundle exec rails db:create:cache db:create:queue db:create:cable 2>/dev/null || true
bundle exec rails db:schema:load:cache db:schema:load:queue db:schema:load:cable

# Start Puma web server
bundle exec puma -C config/puma.rb

