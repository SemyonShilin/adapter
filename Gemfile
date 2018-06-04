source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
ruby '2.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'telegram-bot-ruby', git: 'git@github.com:Scumfunk/telegram-bot-ruby.git'
  gem 'net-http-persistent'
  gem 'activesupport'
end




# group :production do
#   # git@github.com:ShilinSemyon/telegram-bot.git
#   gem 'telegram-bot-types'
#   gem 'telegram-bot', github: 'ShilinSemyon/telegram-bot', branch: :proxy
#   # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#   gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
#   gem 'bootsnap', '>= 1.1.0', require: false
#   gem 'rails', '~> 5.2.0'
#
#
#   # Use Puma as the app server
#   gem 'puma', '~> 3.11'
# end
# gem 'telegram-bot', path: '../../../../../telegram-bot'
gem 'debbie', '~> 2.0.0'

# gem 'rubocop', require: false
gem 'dotenv-rails', '~> 2.2'
