# frozen_string_literal: true

require "rails"

module TornaSdk
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "lib/tasks/torna.rake"
    end
  end
end
