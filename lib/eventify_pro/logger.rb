# frozen_string_literal: true

require 'logger'

module EventifyPro
  # Default Logger for EventifyPro::Client.
  # Used if logger is not provided during client initialization
  class DefaultLogger
    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    rescue
      false
    end

    def info(message)
      @logger.info(message)
    rescue
      false
    end
  end
end
