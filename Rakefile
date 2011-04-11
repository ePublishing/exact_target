require 'rake'
require 'echoe'
require 'rake/rdoctask'
require 'spec/rake/spectask'

task :default => :gem

Echoe.new("exact-target") do |s|
  s.author = "David McCullars"
  s.project = "exact-target"
  s.email = "dmccullars@ePublishing.com"
  s.url = "http://github.com/ePublishing/exact_target"
  s.docs_host = "http://rdoc.info/github/ePublishing/exact_target/master/frames"
  s.rdoc_pattern = /README|TODO|LICENSE|CHANGELOG|BENCH|COMPAT|exceptions|behaviors|exact-target.rb/
  s.clean_pattern += ["ext/lib", "ext/include", "ext/share", "ext/libexact-target-?.??", "ext/bin", "ext/conftest.dSYM"]
  s.summary = <<DONE
This is a pure-ruby implementation of the ExactTarget api.
For more information consule http://www.exacttarget.com/.
DONE
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--options', %q("spec/spec.opts")]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'generate API documentation to doc/rdocs/index.html'
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.rdoc'
  rd.rdoc_files.include 'README.rdoc', 'CHANGELOG', 'lib/**/*.rb'
  rd.rdoc_files.exclude '**/string_ext.rb', '**/net_https_hack.rb'
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--all'
  rd.options << '--fileboxes'
end
