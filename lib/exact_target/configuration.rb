module ExactTarget
  # Used to set up and modify settings for ExactTarget
  class Configuration

    OPTIONS = [:base_url, :username, :password,
               :http_open_timeout, :http_read_timeout, :http_proxy].freeze

    # The (optional) base URL for accessing ExactTarget (can be http or https).
    # Defaults to 'https://api.dc1.exacttarget.com/integrate.aspx'
    attr_accessor :base_url

    # The (required) ExactTarget username for making requests
    attr_accessor :username

    # The (required) ExactTarget password for making requests
    attr_accessor :password

    # The (optional) logger for outputting request/resposne xml
    attr_accessor :logger

    # The (optional) HTTP open timeout in seconds (defaults to 2).
    attr_accessor :http_open_timeout

    # The (optional) HTTP read timeout in seconds (defaults to 5).
    attr_accessor :http_read_timeout

    # The (optional) HTTP proxy url
    attr_accessor :http_proxy

    def initialize
      @base_url                 = 'https://api.dc1.exacttarget.com/integrate.aspx'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
    end

    def valid?
      [:base_url, :username, :password].none? { |f| send(f).nil? }
    end

    def secure?
      !!(base_url =~ /^https:/i)
    end

  end
end
