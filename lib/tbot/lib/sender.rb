require_relative '../config/config'
require_relative 'parser'

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
    message = Parser.new(response: @message, kind: :supervisor).supervisor_formatted
    ErlPort::Erlang::cast(@listener, Tuple.new([:receive_message, message]))
    @logger.debug "sending to supervisor #{@message}"
  end

  def send_to_user
    message = Parser.new(response: @message, kind: :user).user_formatted
    message.each do |m|
      @bot.api.send_message(chat_id: @message.dig('data', 'chat', 'id'), text: m[:text],  reply_markup: m[:object])
      @logger.debug "sending to user #{message}"
    end
  end
end