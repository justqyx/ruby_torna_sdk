# frozen_string_literal: true

require "bundler/setup"
require "rake/testtask"

Bundler.require(:default, :development, :test)

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
end

task default: :test
