require_relative 'multi_logger'

class Configurator
  def configure
  end

  def get_token
  end

  def get_logger
    Logger.new MultiLogger.new(STDERR, File.open('tbot.log', 'a'))
  end
end