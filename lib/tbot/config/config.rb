require 'logger'

class Configurator
  def configure

  end

  def get_token
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end
end