source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'dotenv-rails'

# OAuth authentication
gem 'omniauth-facebook'
gem 'omniauth-mail_ru'
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'omniauth-twitter'
gem 'omniauth-vkontakte'

gem 'paypal-sdk-rest'

gem 'autoprefixer-rails', group: :production

gem 'biovision-base', git: 'https://github.com/Biovision/biovision-base.git'
# gem 'biovision-base', path: '/Users/maxim/Projects/Biovision/gems/biovision-base'
gem 'biovision-post', git: 'https://github.com/Biovision/biovision-post.git'
# gem 'biovision-post', path: '/Users/maxim/Projects/Biovision/gems/biovision-post'
gem 'biovision-comment', git: 'https://github.com/Biovision/biovision-comment.git'
# gem 'biovision-comment', path: '/Users/maxim/Projects/Biovision/gems/biovision-comment'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'mina'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
