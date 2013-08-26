# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Cookitor::Application.config.secret_token = '69940e024deedb28b5d20071e9a4ca7e7eb23cd09b7ccf6ad2211e92d0c9f5554b50c2920ebd3a01c2c03791928ddfa794fbad1bdda33a5f0b9382476bf7be58'
unless ENV['RAILS_SECRET_KEY_BASE'].blank?
  Cookitor::Application.config.secret_key_base = ENV['RAILS_SECRET_KEY_BASE']
else
  Rails.logger.warn "ENV['RAILS_SECRET_KEY_BASE'] not set."
end
