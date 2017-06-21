# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Eventify allows to publish events from Ruby applications
module EventifyPro
  Error = Class.new(StandardError)
  ServiceUnavailableError = Class.new(Error)

  # Client that allows to publish events
  class Client
    BASE_URI = 'http://api.eventify.pro'

    def initialize(api_key: nil, raise_errors: false)
      @api_key = api_key || ENV['EVENTIFY_API_KEY']
      if @api_key.to_s.empty?
        raise Error, 'Please provide api_key param or set EVENTIFY_API_KEY env variable' # rubocop:disable LineLength
      end

      @raise_errors = raise_errors
    end

    def publish(type:, data:)
      response = post_request('events', type, data)

      error_message = response['error_message'] || ''
      raise Eventify::Error, error_message unless error_message.empty?

      true
    rescue => e
      process_error(e)
    end

    private

    attr_reader :api_key, :raise_errors

    def process_error(error)
      return false unless raise_errors

      raise error if error.is_a?(Error)
      raise Error, 'Could not publish event'
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
      raise Error, 'Could not process response from Eventify'
    rescue
      raise ServiceUnavailableError, 'Eventify is currently unavaliable'
    end

    def headers
      {
        'Authorization' => api_key,
        'Content-Type' => 'application/json; charset=utf-8'
      }
    end
  end
end
