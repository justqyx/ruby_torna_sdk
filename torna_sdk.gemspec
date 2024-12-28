# frozen_string_literal: true

require_relative "lib/torna_sdk/version"

Gem::Specification.new do |spec|
  spec.name = "torna_sdk"
  spec.version = TornaSdk::VERSION
  spec.authors = ["JustQyx"]
  spec.email = ["hzuqiuyuanxin@gmail.com"]

  spec.summary = "upload rails routes to torna api doc"
  spec.description = "upload rails routes to torna api doc"
  spec.homepage = "https://github.com/justqyx/ruby_torna_sdk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.6"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.files.reject! { |f| f.match(%r{^gemfiles/}) }
  spec.files.reject! { |f| f == "Appraisals" }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5.0"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rubocop", ">= 1.21"
  spec.add_development_dependency "webmock"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
