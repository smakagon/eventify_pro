# frozen_string_literal: true

require 'logger'

module EventifyPro
  # eventify default log
  class DefaultLogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end

    def info(message)
      @logger.info(message)
    end
  end
end
