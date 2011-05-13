require 'rubygems'

unless RUBY_VERSION.to_f < 1.9
  require 'simplecov'
  begin
    require 'simplecov-rcov' # Formats in rcov format (so jenkins can consume)
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  rescue Exception => e
    # Ignore if it isn't installed
  end
  SimpleCov.start
end

require 'exact_target'
require 'yaml'
