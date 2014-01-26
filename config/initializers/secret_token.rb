# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

Cookitor::Application.config.secret_token = ENV['RAILS_SECRET_TOKEN'] || '745b6c90b4ca43d246d3259a486e7adde4db1270dafd1479a74498aff773a53f4d1e03fa086c32a9e8998fce5bb4a1a7875a7c7c7055705d0dde15796fb4a820'
# HEROKU setup:
# heroku config:set RAILS_SECRET_TOKEN="..."

unless ENV['RAILS_SECRET_KEY_BASE'].blank?
  Cookitor::Application.config.secret_key_base = ENV['RAILS_SECRET_KEY_BASE']
else
  Rails.logger.warn "ENV['RAILS_SECRET_KEY_BASE'] not set."
end
