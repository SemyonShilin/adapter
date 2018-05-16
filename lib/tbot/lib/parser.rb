class Parser
  attr_accessor :response, :fields, :kind

  def initialize(response: , kind:)
    @response = response
    @kind = kind
    @fields = common_fields_hash if @kind == :supervisor
  end

  def user_formatted
    @response.dig('data', 'messages').map { |m| parse_each(m) }
  end

  def supervisor_formatted
    p @response.class
    if @response.is_a? Telegram::Bot::Types::Message
      parse_message
    elsif @response.is_a? Telegram::Bot::Types::CallbackQuery
      parse_callback_query
    end

    JSON.dump(@fields)
  end

  private

  def parse_each(m)
    object =
      if m['menu']
        case m['menu']['type']
        when 'inline'
          kb = m['menu']['items'].map{ |x| format_menu_item(x) }
          Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        when 'keyboard'
          Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [m['menu']['items'].map{|x| x['name']}])
        when 'auth'
          kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Войти', url: m['menu']['items'][0]['url'] )]
          Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        else
          []
        end
      end
    { text: m['body'], object: object }
  end

  def format_menu_item(menu_item)
    if menu_item['type'] == 'url' || menu_item['url']
      Telegram::Bot::Types::InlineKeyboardButton.new(text: menu_item['name'], url: menu_item['url'])
    elsif menu_item['type'] == 'transition' || menu_item['code']
      Telegram::Bot::Types::InlineKeyboardButton.new(text: menu_item['name'], callback_data: menu_item['code'])
    end
  end

  def parse_message
    @fields.merge!(data: { is_menu_clicked: false, message: @response.text })
    @fields.merge!(chat: { id: @response.chat.id,
                           type: @response.chat.type})
    @fields.merge!(text: @response.text)
    @fields.merge!(date: @response.date)
  end

  def parse_callback_query
    @fields.merge!(data: { is_menu_clicked: true, message: @response.data })
    @fields.merge!(chat: { id: @response.message.from.id,
                           type: @response.message.from.is_bot})
    @fields.merge!(text: @response.message.text)
    @fields.merge!(date: @response.message.date)
  end

  def common_fields_hash
    {
      bot_id: 1,
      platform: :telegram,
      client_id: @response.from.id,
      user:
        {
          id: @response.from.id,
          is_bot: @response.from.is_bot,
          first_name:  @response.from.first_name,
          last_name: @response.from.last_name,
          username:  @response.from.username
        }
    }
  end
end