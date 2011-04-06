require 'rake'
require 'rubygems'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

task :default => :gem

gem_spec = Gem::Specification.new do |s|
  s.name = %q{exact-target}
  s.version = File.read(File.expand_path '../CHANGELOG', __FILE__)[/v([\d\.]+)\./, 1]
  s.author = "David McCullars"
  s.email = "dmccullars@ePublishing.com"
  s.homepage = "https://github.com/ePublishing/exact_target"
  s.files = FileList["lib/**/*"].to_a
  s.require_path = "lib"
  s.description = "ExactTarget API implementation"
  s.summary = <<DONE
This is a pure-ruby implementation of the ExactTarget api.
For more information consule http://www.exacttarget.com/.
DONE
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_tar = true
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--options', %q("spec/spec.opts")]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
