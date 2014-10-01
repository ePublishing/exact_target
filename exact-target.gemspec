# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "exact-target"
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["David McCullars, Paul Nock, Jeff Ching"]
  s.date = "2012-02-09"
  s.description = "This is a pure-ruby implementation of the ExactTarget api.\nFor more information consule http://www.exacttarget.com/.\n"
  s.email = ["dmccullars@ePublishing.com", "nocksf@gmail.com"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.rdoc", "lib/exact-target.rb"]
  s.files = ["CHANGELOG", "Gemfile", "Gemfile.lock", "LICENSE", "Manifest", "README.rdoc", "Rakefile", "exact-target.gemspec", "lib/exact-target.rb", "lib/exact_target.rb", "lib/exact_target/builder_ext.rb", "lib/exact_target/configuration.rb", "lib/exact_target/error.rb", "lib/exact_target/net_https_hack.rb", "lib/exact_target/request_builder.rb", "lib/exact_target/response_class.erb", "lib/exact_target/response_classes.rb", "lib/exact_target/response_handler.rb", "lib/exact_target/string_ext.rb", "lib/exacttarget.rb", "spec/exact_target/net_https_hack_spec.rb", "spec/exact_target/response_handler_spec.rb", "spec/exact_target/string_ext_spec.rb", "spec/exact_target_data.yml", "spec/exact_target_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/ePublishing/exact_target"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Exact-target", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "exact-target"
  s.rubygems_version = "1.8.10"
  s.summary = "This is a pure-ruby implementation of the ExactTarget api. For more information consule http://www.exacttarget.com/."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
