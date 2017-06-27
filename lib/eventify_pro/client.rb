# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Eventify
module EventifyPro
  Error = Class.new(StandardError)
  ServiceUnavailableError = Class.new(Error)

  # EventifyPro::Client allows to publish events.
  #
  # To instantiate very basic client use this code:
  # `client = EventifyPro::Client.new(api_key: 'personal_api_key')`
  # Then use it this way:
  # `client.publish(type: 'OrderPosted', data: { order_id: 10, amount: 3000 })`
  #
  # Configuration
  #
  # raise_errors:
  # By default client will not throw any exception. `publish` will return either
  # `true` or `false` depending on the result of publishing.
  # It's possible to configure client to throw an `EventifyPro::Error`
  # if exception wasn't published.
  # `EventifyPro::Client.new(api_key: 'personal_api_key', raise_errors: true)`
  #
  # logger:
  # By default client will write errors to STDOUT, but it's possible to pass
  # any custom logger that responds to .info(message):
  # `EventifyPro::Client.new(api_key: 'personal_api_key', logger: Rails.logger)`
  class Client
    BASE_URI = 'http://api.eventify.pro/v1'

    def initialize(api_key: nil, raise_errors: false, logger: EventifyPro::DefaultLogger.new) # rubocop:disable LineLength
      @api_key = api_key || ENV['EVENTIFY_PRO_API_KEY']
      validate_api_key_presence!

      @raise_errors = raise_errors
      @logger = logger
    end

    def publish(type:, data:)
      response = post_request('events', type, data)

      error_message = response['error_message'] || ''
      raise Error, error_message unless error_message.empty?

      true
    rescue => e
      process_error(e, 'publish', type: type, data: data)
      false
    end

    private

    attr_reader :api_key, :raise_errors, :logger

    def process_error(error, method, params)
      error = Error.new('Could not publish event') unless error.is_a?(Error)
      log_error(error.message, method, params)

      raise error if raise_errors
    end

    def log_error(message, method, params)
      message = "[EVENTIFY_PRO] ##{method} call returned error: #{message}\nParams: #{params}" # rubocop:disable LineLength
      return logger.info(message) if logger.respond_to?(:info)

      raise NotImplementedError, 'Logger should respond to #info(message) call'
    end

    def post_request(end_point, type, data)
      url = "#{BASE_URI}/#{end_point}"

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, headers)

      request.set_form_data(type: type, data: data.to_json)

      response = http.request(request)
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise Error, 'Could not process response from EventifyPro'
    rescue
      raise ServiceUnavailableError, 'EventifyPro is currently unavaliable'
    end

    def headers
      {
        'Authorization' => api_key,
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def validate_api_key_presence!
      return unless api_key.to_s.empty?

      raise Error, 'Please provide api_key param or set EVENTIFY_PRO_API_KEY environment variable' # rubocop:disable LineLength
    end
  end
end
