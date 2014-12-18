# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_myschool_session',
  :secret      => 'e0df7285fdba2da70b63776ced9925b93850c97f5a99915e27423f5c6a3e77dc4a5045ba6ac286cb482b4ddea79d5ea16ea1b7716b71393a7235b26a3ad287d6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
