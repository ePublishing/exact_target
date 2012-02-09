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

    def configure(username=nil, password=nil)
      self.configuration ||= Configuration.new
      configuration.username = username if username
      configuration.password = password if password
      yield(configuration) if block_given?
      self.builder = RequestBuilder.new(configuration)
      self.handler = ResponseHandler.new(configuration)
      nil
    end

    def verify_configure
      raise "ExactTarget must be configured before using" if configuration.nil? or !configuration.valid?
    end

    def log(level, message)
      verify_configure
      configuration.logger.send(level, message) unless configuration.logger.nil?
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

      data = "qf=xml&xml=#{URI.escape(URI.escape(request), "&")}"
      uri = URI.parse(configuration.base_url)

      http = net_http_or_proxy.new(uri.host, uri.port)
      http.use_ssl = configuration.secure?
      http.open_timeout = configuration.http_open_timeout
      http.read_timeout = configuration.http_read_timeout

      if configuration.http_method.to_s == "post"
        resp = http.post(uri.request_uri, data)
      else
        resp = http.get(uri.request_uri + "?" + data)
      end

      if resp.is_a?(Net::HTTPSuccess)
        resp.body
      else
        resp.error!
      end
    end


    # Define ExactTarget methods
    (RequestBuilder.instance_methods(false) & ResponseHandler.instance_methods(false)).each do |m|
      define_method(m) do |*args|
        call(m, *args)
      end
    end

    private

    def net_http_or_proxy
      if configuration.http_proxy
        proxy_uri = URI.parse(configuration.http_proxy)
        Net::HTTP.Proxy(proxy_uri.host, proxy_uri.port)
      else
        Net::HTTP
      end
    end

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
  end

end
