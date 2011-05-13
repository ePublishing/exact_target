require 'rubygems'

unless RUBY_VERSION.to_f < 1.9
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'Libraries', 'lib'
  end
end

require 'exact_target'
require 'yaml'
