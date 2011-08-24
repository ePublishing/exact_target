module ExactTarget
  # Used to set up and modify settings for ExactTarget
  class Configuration

    OPTIONS = [:base_url, :username, :password, :readonly, :email_whitelist, :email_blacklist,
               :http_method, :http_open_timeout, :http_read_timeout, :http_proxy].freeze
    STANDARD_READONLY_CALLS = [:list_add, :list_edit, :list_import, :list_delete,
                               :subscriber_add, :subscriber_edit, :subscriber_delete, :subscriber_masterunsub,
                               :email_add, :email_add_text, :job_send].freeze

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

    # The HTTP method to make the request with
    attr_accessor :http_method

    # The (optional) readonly flag (defaults to false)
    attr_accessor :readonly

    # (optional) limiting triggeredsend email addresses
    attr_accessor :email_whitelist
    attr_accessor :email_blacklist

    def initialize
      @base_url                 = 'https://api.dc1.exacttarget.com/integrate.aspx'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @http_method              = "get"
      @readonly                 = []
    end

    def valid?
      [:base_url, :username, :password].none? { |f| send(f).nil? }
    end

    def secure?
      !!(base_url =~ /^https:/i)
    end

  end
end
