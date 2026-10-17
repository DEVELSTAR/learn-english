#!/usr/bin/env bash
# exit on error
set -o errexit

mkdir -p storage tmp/pids

# Run pending database migrations on primary database (Supabase)
bundle exec rails db:migrate

# Start Puma web server
bundle exec puma -C config/puma.rb

