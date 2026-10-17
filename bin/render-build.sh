#!/usr/bin/env bash
# exit on error
set -o errexit

mkdir -p storage tmp/pids

bundle install
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:clean

bundle exec rails db:prepare

