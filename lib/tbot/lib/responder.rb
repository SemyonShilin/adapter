require_relative '../lib/sender'
require_relative '../lib/parser'

class MessageResponder
  attr_reader :message, :bot, :listener, :kind, :token
  include ErlPort::Erlang

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @listener = options[:listener]
    @token = options[:token]
    @kind = options[:kind]
  end

  def respond
    case @kind
    when :user
      message_send_to_user
    when :supervisor
      message_send_to_supervisor
    else
      :sorry
    end
  end

  private

  def message_send_to_user
    MessageSender.new(bot: @bot, message: @message, token: @token).send_to_user
  end

  def message_send_to_supervisor
    MessageSender.new(listener: @listener, message: @message).send_to_supervisor
  end
end