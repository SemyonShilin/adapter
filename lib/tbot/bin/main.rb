require 'telegram/bot'
require_relative '../config/config'
require_relative '../lib/responder'

config = Configurator.new

# token = config.get_token
$logger = config.get_logger

$logger.debug 'Starting bot'

def run_bot(pid, token, listener, ex_module=nil)
  p 'run_bot!!!!!!'
  Telegram::Bot::Client.run(token) do |bot|
    $logger.debug bot
    bot.listen do |message|
      options = { bot: bot, message: message, listener: listener, kind: :supervisor }
      $logger.debug "#{message.from.first_name}: #{message}"
      MessageResponder.new(options).respond
    end
  end
end

def register_handler(dest, token, listener)
  puts "register_handler!!!!!!!!!!!!!!!!"
  set_message_handler {|message|
    $logger.debug "ruby recieve message"
    $logger.debug message
    Telegram::Bot::Client.run(token) do |bot|
      options = { bot: bot, message: JSON.parse(message), token: token, kind: :user }
      MessageResponder.new(options).respond
    end
  }
  ErlPort::Erlang::self()
end