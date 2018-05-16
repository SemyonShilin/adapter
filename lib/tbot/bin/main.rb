require 'telegram/bot'
require_relative '../config/config'
require_relative '../lib/responder'

config = Configurator.new

$logger = config.get_logger

$logger.debug 'Starting bot'

def run_bot(pid, token, listener, ex_module=nil)
  $logger.debug 'bot start'
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      options = { bot: bot, message: message, listener: listener, kind: :supervisor }
      $logger.debug "#{message.from.first_name} (chat_id - #{message.chat.id}) : #{message.text}"
      MessageResponder.new(options).respond
    end
  end
end

def register_handler(dest, token, listener)
  $logger.debug 'register handler start '
  set_message_handler {|message|
    Telegram::Bot::Client.run(token) do |bot|
      options = { bot: bot, message: message = JSON.parse(message), token: token, kind: :user }
      $logger.debug "#{message.dig('chat', 'id')} : #{message['text']} "
      MessageResponder.new(options).respond
    end
  }
  ErlPort::Erlang::self()
end