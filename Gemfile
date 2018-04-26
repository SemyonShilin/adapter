source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'telegram-bot-ruby', git: 'git@github.com:Scumfunk/telegram-bot-ruby.git'
gem 'dotenv-rails', '~> 2.2'
gem 'activesupport'
gem 'net-http-persistent'
