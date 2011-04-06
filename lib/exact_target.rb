require 'date'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'uri'

require 'exact_target/net_https_hack'
require 'exact_target/builder_ext'
require 'exact_target/string_ext'

require 'exact_target/configuration'
require 'exact_target/error'
require 'exact_target/request_builder'
require 'exact_target/response_classes'
require 'exact_target/response_handler'

# The ExactTarget library is a ruby implementation of the ExactTarget
# email marketing api.  It allows for list/subscriber management,
# email creation, and job initiation.
module ExactTarget

  VERSION = File.read(File.expand_path '../../CHANGELOG', __FILE__)[/v([\d\.]+)\./, 1]
  LOG_PREFIX = "** [ExactTarget] "

  extend ExactTarget::ResponseClasses

  class << self
    # The builder object is responsible for building the xml for any given request
    attr_accessor :builder

    # The handler object is responsible for handling the xml response and returning
    # response data
    attr_accessor :handler

    # A ExactTarget configuration object. Must act like a hash and return sensible
    # values for all ExactTarget configuration options. See ExactTarget::Configuration.
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.builder = RequestBuilder.new(configuration)
      self.handler = ResponseHandler.new(configuration)
      nil
    end

    def verify_configure
      raise "ExactTarget must be configured before using" unless configuration.valid?
    end

    def log(level, message)
      verify_configure
      configuration.logger.send(level, message) unless configuration.nil? or configuration.logger.nil?
    end

    def call(method, *args, &block)
      verify_configure

      request = builder.send(method, *args, &block)
      log :debug, "#{LOG_PREFIX}REQUEST: #{request}"

      response = send_to_exact_target(request)
      log :debug, "#{LOG_PREFIX}RESPONSE: #{response}"

      response = parse_response_xml(response)

      handler.send(method, response)
    end

    def send_to_exact_target(request)
      verify_configure
      uri = URI.parse "#{configuration.base_url}?qf=xml&xml=#{URI.escape request}"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = configuration.secure?
      http.open_timeout = configuration.http_open_timeout
      http.read_timeout = configuration.http_read_timeout
      resp = http.get(uri.request_uri)
      if resp.is_a?(Net::HTTPSuccess)
        resp.body
      else
        resp.error!
      end
    end

    def exact_target_methods
      verify_configure
      builder.public_methods(false) & handler.public_methods(false)
    end

    private

    def parse_response_xml(xml)
      verify_configure
      resp = Nokogiri.parse(xml)
      error = resp.xpath('//error[1]').first
      error_description = resp.xpath('//error_description[1]').first
      if error and error_description
        raise Error.new(error.text.to_i, error_description.text)
      else
        resp
      end
    end

    def method_missing(method, *args, &block)
      if builder.respond_to?(method) and handler.respond_to?(method)
        call(method, *args, &block)
      else
        super
      end
    end
  end

end
