require 'telegram/bot'

include ErlPort::Erlang

def register_handler(dest, token, listener)
  puts "register_handler!!!!!!!!!!!!!!!!"
  set_message_handler {|message|
    p "ruby recieve message"
    p message
    send_message_to_user(token, JSON.parse(message))
  }
  ErlPort::Erlang::self()
end

def run_bot(pid, token, listener, ex_module=nil)
  p 'run_bot!!!!!!'
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      puts "telegram receive message"
      puts message.inspect
      send_message_to_supervisor(listener, message)
    end
  end
end

def send_message_to_supervisor(listener, message)
  parsed_message = {
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
  ErlPort::Erlang::cast(listener, Tuple.new([:message, JSON.dump(parsed_message)]))
end

def send_message_to_user(token, message)
  Telegram::Bot::Client.run(token) do |bot|
    bot.api.send_message(chat_id: message["chat"]["id"], text: message["text"])
  end
end

def get_message_id(message)
  if message.class == Telegram::Bot::Types::CallbackQuery
    message.message.message_id
  else
    message.message_id
  end
end

def format_menu_item(menu_item)
  if menu_item["type"] == "url" || menu_item["url"]
    Telegram::Bot::Types::InlineKeyboardButton.new(text: menu_item["name"], url: menu_item["url"])
  elsif menu_item["type"] == "transition" || menu_item["code"]
    Telegram::Bot::Types::InlineKeyboardButton.new(text: menu_item["name"], callback_data: menu_item["code"])
  end
end

def send_message_to_user(message, client_id, bot)
  message["data"]["messages"].each do |m|
    answers = []
    if m['menu']
      case m['menu']['type']
      when 'inline'
        kb = m['menu']['items'].map{ |x| format_menu_item(x) }
        answers = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      when 'keyboard'
        answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [m['menu']['items'].map{|x| x["name"]}])
      when 'auth'
        kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: "Войти", url: m['menu']['items'][0]["url"] )]
        answers = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      else
        answers = []
      end
    end
    bot.api.send_message(chat_id: client_id, text: m["body"], reply_markup: answers)
    #bot.api.send_message(chat_id:message["data"]["client_id"] , text: m["message"])
  end
end

puts "Telegram listener initialized\n"
Telegram::Bot::Client.run(TOKEN) do |bot|
  # begin
  bot.listen do |message|
    puts "#{DateTime.now}: message id=#{get_message_id(message)} from #{message.from.id} received\n"

    res = {
      bot_id: 1,
      platform: 'telegram',
      client_id: message.from.id,
      data:{}
    }
    if message.class == Telegram::Bot::Types::CallbackQuery
      res[:data] = {is_menu_clicked: true, message: message.data}
    else
      res[:data] = {is_menu_clicked: false, message: message.text}
    end
    send_message_to_user(res, message&.from&.id, bot)
    puts "#{DateTime.now}: message id=#{get_message_id(message)} from #{message.from.id} successfully responded\n"
  end
end

def send_message_to_user(token, message)
  Telegram::Bot::Client.run(token) do |bot|
    bot.api.send_message(chat_id: message["chat"]["id"], text: message["text"])
  end
end