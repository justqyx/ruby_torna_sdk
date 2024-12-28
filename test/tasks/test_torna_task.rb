# frozen_string_literal: true

require "minitest/autorun"
require "rails"
require "rails/application"
require "torna_sdk"
require "rake"

module TestApp
  class Application < Rails::Application
    config.eager_load = false
  end
end

class TornaTaskTest < Minitest::Test
  def setup
    Rails.application = TestApp::Application.new

    Rails.application.routes.draw do
      get "test/index"
      post "test/create"
      put "test/update"
      delete "test/destroy"
    end

    Rake.application.init
    Rake.application.load_rakefile

    Dir.glob("lib/tasks/*.rake").each { |r| load r }
  end

  def test_torna_print_and_upload
    require "webmock/minitest"
    WebMock.enable!

    stub_request(:post, "http://localhost:7700/api")
      .to_return(
        status: 200,
        body: '{"code":"0","data":{},"msg":""}',
        headers: { "Content-Type" => "application/json" }
      )

    Rake::Task["torna:print_and_upload"].invoke

    assert_requested(:post, "http://localhost:7700/api", times: 1)
  ensure
    WebMock.disable!
  end
end
