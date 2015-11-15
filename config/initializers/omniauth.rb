Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rails.application.secrets.twitter['api_key'], Rails.application.secrets.twitter['api_secret']
  provider :facebook, Rails.application.secrets.fb['app_id'], Rails.application.secrets.fb['app_secret']
  provider :mail_ru, Rails.application.secrets.mailru['app_id'], Rails.application.secrets.mailru['app_private']
end