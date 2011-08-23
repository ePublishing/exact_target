# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{exact-target}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["David McCullars"]
  s.date = %q{2011-04-11}
  s.description = %q{This is a pure-ruby implementation of the ExactTarget api.
For more information consule http://www.exacttarget.com/.
}
  s.email = %q{dmccullars@ePublishing.com}
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.rdoc"]
  s.files = ["CHANGELOG", "LICENSE", "README.rdoc", "Rakefile", "lib/exact_target.rb", "lib/exact_target/builder_ext.rb", "lib/exact_target/configuration.rb", "lib/exact_target/error.rb", "lib/exact_target/net_https_hack.rb", "lib/exact_target/request_builder.rb", "lib/exact_target/response_class.erb", "lib/exact_target/response_classes.rb", "lib/exact_target/response_handler.rb", "lib/exact_target/string_ext.rb", "spec/exact_target/net_https_hack_spec.rb", "spec/exact_target/response_handler_spec.rb", "spec/exact_target/string_ext_spec.rb", "spec/exact_target_data.yml", "spec/exact_target_spec.rb", "spec/spec.opts", "Manifest", "exact-target.gemspec"]
  s.homepage = %q{http://github.com/ePublishing/exact_target}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Exact-target", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{exact-target}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{This is a pure-ruby implementation of the ExactTarget api. For more information consule http://www.exacttarget.com/.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
