
require 'rubygems'
require 'logger'
require 'builder'
require 'net/http'
require 'net/https'
require 'nokogiri'

orig = Object::constants.dup
require 'exact_target'

ExactTarget.configure do |c|
  c.username = 'epublishing'  # 'a_user'
  c.password = 'web_2009'     # 'a_pass'
#  c.logger = Logger.new(STDOUT)
end

p ExactTarget.accountinfo_retrieve_attrbs
