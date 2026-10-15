#!/usr/bin/env bash
# exit on error
set -o errexit

mkdir -p storage tmp/pids

# Run database setup / pending migrations / seeds
bundle exec rails db:prepare

# Start Puma web server
bundle exec puma -C config/puma.rb

