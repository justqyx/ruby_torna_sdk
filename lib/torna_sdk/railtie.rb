# frozen_string_literal: true

require "rails"

module TornaSdk
  class Railtie < ::Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "../tasks/*.rake")].each { |f| load f }
    end
  end
end
