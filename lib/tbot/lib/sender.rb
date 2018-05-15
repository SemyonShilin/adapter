require_relative '../config/config'

class MessageSender
  include ErlPort::Erlang

  attr_reader :bot, :text, :logger, :listener, :message, :token

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @message = options[:message]
    @listener = options[:listener]
    @token = options[:token]
    @logger = Configurator.new.get_logger
  end

  def send_to_supervisor
    ErlPort::Erlang::cast(@listener,
                          Tuple.new([:receive_message, JSON.dump(parse_message(@message))]))
    @logger.debug "sending to supervisor #{@message}"
  end

  def send_to_user
    puts 'send_to_user'
    @bot.api.send_message(chat_id: message.dig('chat', 'id'), text: message['text'])
    @logger.debug "sending to user #{message}"
  end

  private

  def parse_message(message)
    {
      bot_id: 1,
      platform: :telegram,
      client_id: message.from.id,
      data: {message: message.text},
      user: {
        id: message.from.id,
        is_bot: message.from.is_bot,
        first_name:  message.from.first_name,
        last_name: message.from.last_name,
        username:  message.from.username
      },
      chat: {
        id: message.chat.id,
        type: message.chat.type
      },
      text: message.text,
      date: message.date
    }
  end
end